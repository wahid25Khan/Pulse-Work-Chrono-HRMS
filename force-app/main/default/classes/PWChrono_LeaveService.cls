/**
 * @description Service class for Leave Management logic
 * Handles complex business logic for leaves to keep triggers clean
 */
public without sharing class PWChrono_LeaveService {
  private class ValidationContext {
    Set<Id> employeeIds = new Set<Id>();
    Set<Id> leaveTypeIds = new Set<Id>();
    Set<Id> leaveIdsToExclude = new Set<Id>();
  }

  /**
   * @description Validate leave balance before insert/update
   */
  public static void validateLeaveBalance(List<PWChrono_Leave__c> leaves) {
    ValidationContext ctx = collectIdsForValidation(leaves);
    if (ctx.employeeIds.isEmpty()) {
      return;
    }

    Map<String, List<PWChrono_Leave_Allocation__c>> allocMap = groupAllocations(
      fetchAllocations(ctx)
    );
    Map<String, List<PWChrono_Leave__c>> leaveMap = groupLeaves(
      fetchExistingLeaves(ctx)
    );

    for (PWChrono_Leave__c newLeave : leaves) {
      processLeaveValidation(newLeave, allocMap, leaveMap);
    }
  }

  private static void processLeaveValidation(
    PWChrono_Leave__c newLeave,
    Map<String, List<PWChrono_Leave_Allocation__c>> allocMap,
    Map<String, List<PWChrono_Leave__c>> leaveMap
  ) {
    if (!isValidStatus(newLeave)) {
      return;
    }

    String key = getGroupKey(newLeave.Employees__c, newLeave.Leave_Type__c);
    PWChrono_Leave_Allocation__c targetAlloc = findMatchingAllocation(
      allocMap.get(key),
      newLeave
    );

    if (targetAlloc == null) {
      newLeave.addError(
        'No active leave allocation found for this leave type and date range.'
      );
      return;
    }

    Decimal usedAndPending = calculateUsedAndPending(
      leaveMap.get(key),
      targetAlloc
    );
    validateBalance(newLeave, targetAlloc, usedAndPending);
  }

  private static void validateBalance(
    PWChrono_Leave__c newLeave,
    PWChrono_Leave_Allocation__c targetAlloc,
    Decimal usedAndPending
  ) {
    Decimal requested = (newLeave.Total_Days__c != null
      ? newLeave.Total_Days__c
      : 0);
    Decimal allocated = (targetAlloc.Total_Leaves_Allocated__c != null
      ? targetAlloc.Total_Leaves_Allocated__c
      : 0);

    if (usedAndPending + requested > allocated) {
      newLeave.addError(
        'Insufficient leave balance. Allocated: ' +
          allocated +
          ', Used/Pending: ' +
          usedAndPending +
          ', Requested: ' +
          requested
      );
    }
  }

  private static ValidationContext collectIdsForValidation(
    List<PWChrono_Leave__c> leaves
  ) {
    ValidationContext ctx = new ValidationContext();
    for (PWChrono_Leave__c leave : leaves) {
      if (
        leave.Employees__c != null &&
        leave.Leave_Type__c != null &&
        (leave.Status__c == PWChrono_Constants.STATUS_SUBMITTED ||
        leave.Status__c == PWChrono_Constants.STATUS_APPROVED)
      ) {
        ctx.employeeIds.add(leave.Employees__c);
        ctx.leaveTypeIds.add(leave.Leave_Type__c);
        if (leave.Id != null) {
          ctx.leaveIdsToExclude.add(leave.Id);
        }
      }
    }
    return ctx;
  }

  private static List<PWChrono_Leave_Allocation__c> fetchAllocations(
    ValidationContext ctx
  ) {
    return [
      SELECT
        Id,
        Employees__c,
        Leave_Type__c,
        Total_Leaves_Allocated__c,
        From_Date__c,
        To_Date__c
      FROM PWChrono_Leave_Allocation__c
      WHERE
        Employees__c IN :ctx.employeeIds
        AND Leave_Type__c IN :ctx.leaveTypeIds
        AND To_Date__c >= TODAY
    ];
  }

  private static List<PWChrono_Leave__c> fetchExistingLeaves(
    ValidationContext ctx
  ) {
    return [
      SELECT
        Id,
        Employees__c,
        Leave_Type__c,
        Total_Days__c,
        From_Date__c,
        To_Date__c,
        Status__c
      FROM PWChrono_Leave__c
      WHERE
        Employees__c IN :ctx.employeeIds
        AND Leave_Type__c IN :ctx.leaveTypeIds
        AND (Status__c = :PWChrono_Constants.STATUS_APPROVED
        OR Status__c = :PWChrono_Constants.STATUS_SUBMITTED)
        AND Id NOT IN :ctx.leaveIdsToExclude
    ];
  }

  private static String getGroupKey(Id empId, Id typeId) {
    return empId + '-' + typeId;
  }

  private static Map<String, List<PWChrono_Leave_Allocation__c>> groupAllocations(
    List<PWChrono_Leave_Allocation__c> listToGroup
  ) {
    Map<String, List<PWChrono_Leave_Allocation__c>> grouped = new Map<String, List<PWChrono_Leave_Allocation__c>>();
    for (PWChrono_Leave_Allocation__c item : listToGroup) {
      String key = getGroupKey(item.Employees__c, item.Leave_Type__c);
      if (!grouped.containsKey(key)) {
        grouped.put(key, new List<PWChrono_Leave_Allocation__c>());
      }
      grouped.get(key).add(item);
    }
    return grouped;
  }

  private static Map<String, List<PWChrono_Leave__c>> groupLeaves(
    List<PWChrono_Leave__c> listToGroup
  ) {
    Map<String, List<PWChrono_Leave__c>> grouped = new Map<String, List<PWChrono_Leave__c>>();
    for (PWChrono_Leave__c item : listToGroup) {
      String key = getGroupKey(item.Employees__c, item.Leave_Type__c);
      if (!grouped.containsKey(key)) {
        grouped.put(key, new List<PWChrono_Leave__c>());
      }
      grouped.get(key).add(item);
    }
    return grouped;
  }

  private static Boolean isValidStatus(PWChrono_Leave__c leave) {
    return leave.Status__c == PWChrono_Constants.STATUS_SUBMITTED ||
      leave.Status__c == PWChrono_Constants.STATUS_APPROVED;
  }

  private static PWChrono_Leave_Allocation__c findMatchingAllocation(
    List<PWChrono_Leave_Allocation__c> allocations,
    PWChrono_Leave__c newLeave
  ) {
    if (allocations == null) {
      return null;
    }
    for (PWChrono_Leave_Allocation__c alloc : allocations) {
      if (isDateInRange(newLeave, alloc)) {
        return alloc;
      }
    }
    return null;
  }

  private static Boolean isDateInRange(
    PWChrono_Leave__c leave,
    PWChrono_Leave_Allocation__c alloc
  ) {
    return (alloc.From_Date__c == null ||
      leave.From_Date__c >= alloc.From_Date__c) &&
      (alloc.To_Date__c == null ||
      leave.To_Date__c <= alloc.To_Date__c);
  }

  private static Decimal calculateUsedAndPending(
    List<PWChrono_Leave__c> existingLeaves,
    PWChrono_Leave_Allocation__c targetAlloc
  ) {
    Decimal usedAndPending = 0;
    if (existingLeaves == null) {
      return 0;
    }

    for (PWChrono_Leave__c existing : existingLeaves) {
      if (isDateOverlap(existing, targetAlloc)) {
        usedAndPending += (existing.Total_Days__c != null
          ? existing.Total_Days__c
          : 0);
      }
    }
    return usedAndPending;
  }

  private static Boolean isDateOverlap(
    PWChrono_Leave__c existing,
    PWChrono_Leave_Allocation__c targetAlloc
  ) {
    return (targetAlloc.From_Date__c == null ||
      existing.From_Date__c >= targetAlloc.From_Date__c) &&
      (targetAlloc.To_Date__c == null ||
      existing.To_Date__c <= targetAlloc.To_Date__c);
  }
}
