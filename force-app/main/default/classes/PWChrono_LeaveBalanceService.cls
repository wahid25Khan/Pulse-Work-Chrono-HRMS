/**
 * @description Service class for Leave Balance calculations
 */
public without sharing class PWChrono_LeaveBalanceService {
  public class LeaveBalanceWrapper {
    @AuraEnabled
    public String leaveTypeId;
    @AuraEnabled
    public String leaveType;
    @AuraEnabled
    public Decimal allocated;
    @AuraEnabled
    public Decimal used;
    @AuraEnabled
    public Decimal pending;
    @AuraEnabled
    public Decimal remaining;
  }

  /**
   * @description Get leave balance for an employee
   */
  public static List<LeaveBalanceWrapper> getLeaveBalance(Id employeeId) {
    List<PWChrono_Leave_Allocation__c> allocations = fetchAllocations(
      employeeId
    );
    if (allocations.isEmpty()) {
      return new List<LeaveBalanceWrapper>();
    }

    Date minDate = calculateMinDate(allocations);
    List<PWChrono_Leave__c> allLeaves = fetchLeaves(employeeId, minDate);

    // Optimize: Pre-calculate usage to avoid nested loops in wrapper creation
    Map<Id, Map<String, Decimal>> usageMap = calculateUsageMap(
      allocations,
      allLeaves
    );

    return createWrappers(allocations, usageMap);
  }

  private static List<PWChrono_Leave_Allocation__c> fetchAllocations(
    Id employeeId
  ) {
    return [
      SELECT
        Id,
        Name,
        Employees__c,
        Leave_Type__c,
        Leave_Type__r.Name,
        New_Leaves_Allocated__c,
        Carry_Forwarded_Leaves__c,
        Total_Leaves_Allocated__c,
        Total_Leaves_Used__c,
        Total_Leaves_Encashed__c,
        From_Date__c,
        To_Date__c
      FROM PWChrono_Leave_Allocation__c
      WHERE Employees__c = :employeeId AND To_Date__c >= TODAY
      ORDER BY Leave_Type__r.Name
    ];
  }

  private static Date calculateMinDate(
    List<PWChrono_Leave_Allocation__c> allocations
  ) {
    Date minDate = allocations[0].From_Date__c;
    for (PWChrono_Leave_Allocation__c alloc : allocations) {
      if (
        alloc.From_Date__c != null &&
        (minDate == null ||
        alloc.From_Date__c < minDate)
      ) {
        minDate = alloc.From_Date__c;
      }
    }
    if (minDate == null) {
      Organization org = [
        SELECT FiscalYearStartMonth
        FROM Organization
        LIMIT 1
      ];
      Integer startMonth = org.FiscalYearStartMonth != null
        ? org.FiscalYearStartMonth
        : 1;
      Integer currentYear = Date.today().year();
      Integer currentMonth = Date.today().month();

      Integer startYear = currentYear;
      if (currentMonth < startMonth) {
        startYear = currentYear - 1;
      }
      minDate = Date.newInstance(startYear, startMonth, 1);
    }
    return minDate;
  }

  private static List<PWChrono_Leave__c> fetchLeaves(
    Id employeeId,
    Date minDate
  ) {
    return [
      SELECT Leave_Type__c, Total_Days__c, From_Date__c, To_Date__c, Status__c
      FROM PWChrono_Leave__c
      WHERE
        Employees__c = :employeeId
        AND Status__c = :PWChrono_Constants.STATUS_SUBMITTED
        AND From_Date__c >= :minDate
      ORDER BY From_Date__c
    ];
  }

  private static Map<Id, Map<String, Decimal>> calculateUsageMap(
    List<PWChrono_Leave_Allocation__c> allocations,
    List<PWChrono_Leave__c> leaves
  ) {
    Map<Id, Map<String, Decimal>> usageMap = new Map<Id, Map<String, Decimal>>();

    // Initialize map
    for (PWChrono_Leave_Allocation__c alloc : allocations) {
      usageMap.put(alloc.Id, new Map<String, Decimal>{ 'pending' => 0 });
    }

    // Group allocations by Leave Type for faster lookup
    Map<Id, List<PWChrono_Leave_Allocation__c>> allocsByType = new Map<Id, List<PWChrono_Leave_Allocation__c>>();
    for (PWChrono_Leave_Allocation__c alloc : allocations) {
      if (!allocsByType.containsKey(alloc.Leave_Type__c)) {
        allocsByType.put(
          alloc.Leave_Type__c,
          new List<PWChrono_Leave_Allocation__c>()
        );
      }
      allocsByType.get(alloc.Leave_Type__c).add(alloc);
    }

    // Iterate leaves and assign to relevant allocations
    for (PWChrono_Leave__c l : leaves) {
      if (allocsByType.containsKey(l.Leave_Type__c)) {
        for (
          PWChrono_Leave_Allocation__c alloc : allocsByType.get(l.Leave_Type__c)
        ) {
          if (isLeaveInAllocationRange(l, alloc)) {
            Map<String, Decimal> leaveUsage = getLeaveUsage(l);
            Map<String, Decimal> currentUsage = usageMap.get(alloc.Id);
            currentUsage.put(
              'pending',
              currentUsage.get('pending') + leaveUsage.get('pending')
            );
          }
        }
      }
    }
    return usageMap;
  }

  private static List<LeaveBalanceWrapper> createWrappers(
    List<PWChrono_Leave_Allocation__c> allocations,
    Map<Id, Map<String, Decimal>> usageMap
  ) {
    List<LeaveBalanceWrapper> balances = new List<LeaveBalanceWrapper>();
    for (PWChrono_Leave_Allocation__c alloc : allocations) {
      balances.add(createBalanceWrapper(alloc, usageMap.get(alloc.Id)));
    }
    return balances;
  }

  private static LeaveBalanceWrapper createBalanceWrapper(
    PWChrono_Leave_Allocation__c alloc,
    Map<String, Decimal> usage
  ) {
    LeaveBalanceWrapper wrapper = new LeaveBalanceWrapper();
    wrapper.leaveTypeId = alloc.Leave_Type__c;
    wrapper.leaveType = (alloc.Leave_Type__r != null &&
      alloc.Leave_Type__r.Name != null)
      ? alloc.Leave_Type__r.Name
      : 'Unknown';
    wrapper.allocated = alloc.Total_Leaves_Allocated__c != null
      ? alloc.Total_Leaves_Allocated__c
      : 0;

    wrapper.used = alloc.Total_Leaves_Used__c != null
      ? alloc.Total_Leaves_Used__c
      : 0;

    Decimal encashed = alloc.Total_Leaves_Encashed__c != null
      ? alloc.Total_Leaves_Encashed__c
      : 0;

    wrapper.pending = usage.get('pending');
    wrapper.remaining =
      wrapper.allocated -
      wrapper.used -
      wrapper.pending -
      encashed;

    return wrapper;
  }

  private static Map<String, Decimal> getLeaveUsage(PWChrono_Leave__c l) {
    Decimal pending = 0;
    Decimal days = (l.Total_Days__c != null ? l.Total_Days__c : 0);

    if (l.Status__c == PWChrono_Constants.STATUS_SUBMITTED) {
      pending = days;
    }
    return new Map<String, Decimal>{ 'pending' => pending };
  }

  private static Boolean isLeaveInAllocationRange(
    PWChrono_Leave__c l,
    PWChrono_Leave_Allocation__c alloc
  ) {
    return (alloc.From_Date__c == null ||
      l.From_Date__c >= alloc.From_Date__c) &&
      (alloc.To_Date__c == null ||
      l.To_Date__c <= alloc.To_Date__c);
  }
}
