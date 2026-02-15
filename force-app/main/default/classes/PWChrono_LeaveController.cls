/**
 * @description Controller for Leave Management LWC Components
 * @author PWChrono Team
 */
public without sharing class PWChrono_LeaveController {
  /**
   * @description Get current employee's leave balance
   * @param employeeId Optional employee ID (Portal_Users__c). If null, uses current user's employee record.
   * @return List of leave allocations with balance details
   */
  @AuraEnabled(cacheable=true)
  public static List<PWChrono_LeaveBalanceService.LeaveBalanceWrapper> getMyLeaveBalance(
    String employeeId,
    String sessionToken
  ) {
    try {
      Id targetEmployeeId;
      if (UserInfo.getUserType() == 'Guest') {
        targetEmployeeId = PWChrono_GuestSession.requireVerifiedPortalUserId(
          employeeId,
          sessionToken
        );
      } else if (String.isNotBlank(employeeId)) {
        targetEmployeeId = (Id) employeeId;
      } else {
        targetEmployeeId = PWChrono_Utils.getCurrentEmployeeId(UserInfo.getUserId());
      }

      if (targetEmployeeId == null) {
        throw new AuraHandledException(
          'No employee record found for current user.'
        );
      }

      return PWChrono_LeaveBalanceService.getLeaveBalance(targetEmployeeId);
    } catch (Exception e) {
      PWChrono_Logger.error('Error fetching leave balance: ');
      PWChrono_Logger.error('Stack trace: ' + e.getStackTraceString());
      throw new AuraHandledException(
        'Error fetching leave balance: '
      );
    }
  }

  /**
   * @description Get leave applications for current employee
   * @param statusFilter Status filter (All, Draft, Submitted, Approved, Rejected)
   * @param startDate Optional start date filter
   * @param endDate Optional end date filter
   * @param employeeId Optional employee ID (Portal_Users__c). If null, uses current user's employee record.
   * @return List of leave applications
   */
  @AuraEnabled(cacheable=false)
  @SuppressWarnings('PMD.ApexSOQLInjection')
  public static List<PWChrono_Leave__c> getMyLeaves(
    String statusFilter,
    Date startDate,
    Date endDate,
    String employeeId,
    String sessionToken
  ) {
    try {
      Id targetEmployeeId;

      if (UserInfo.getUserType() == 'Guest') {
        // Guest: must present a valid portal session token, and can only access own data.
        targetEmployeeId = PWChrono_GuestSession.requireVerifiedPortalUserId(
          employeeId,
          sessionToken
        );
      } else {
        Id currentUserId = UserInfo.getUserId();
        Id currentEmployeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);
        if (currentEmployeeId == null) {
          throw new AuraHandledException('No employee record found for current user.');
        }

        // Security Check: Only Admins can view other employees' data
        if (String.isNotBlank(employeeId) && employeeId != currentEmployeeId) {
          if (PWChrono_AccessController.isAdmin(currentEmployeeId)) {
            targetEmployeeId = (Id) employeeId;
          } else {
            // If not admin, force view own data
            targetEmployeeId = currentEmployeeId;
          }
        } else {
          targetEmployeeId = currentEmployeeId;
        }
      }

      String query =
        'SELECT Id, Name, Employees__c, Leave_Type__c, Leave_Type__r.Name, ' +
        'From_Date__c, To_Date__c, Total_Days__c, Half_Day__c, ' +
        'Reason__c, Status__c, Approvers__c, Approvers__r.Name, ' +
        'Approval_Date__c, Rejection_Reason__c, CreatedDate ' +
        'FROM PWChrono_Leave__c ' +
        'WHERE Employees__c = :targetEmployeeId ';

      if (statusFilter != null && statusFilter != 'All') {
        query += 'AND Status__c = :statusFilter ';
      }

      if (startDate != null) {
        query += 'AND From_Date__c >= :startDate ';
      }

      if (endDate != null) {
        query += 'AND To_Date__c <= :endDate ';
      }

      Integer queryLimit = PWChrono_Constants.DEFAULT_QUERY_LIMIT;
      query += ' ORDER BY From_Date__c DESC LIMIT :queryLimit';

      return (List<PWChrono_Leave__c>) Database.query(query);
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      String detail = (Test.isRunningTest() && String.isNotBlank(e.getMessage()))
        ? (' ' + e.getMessage())
        : '';
      throw new AuraHandledException('Error fetching leaves.' + detail);
    }
  }

  /**
   * @description Get team leaves for manager approval
   * @return List of pending team leave applications
   */
  @AuraEnabled(cacheable=false)
  public static List<PWChrono_Leave__c> getTeamLeavesForApproval() {
    try {
      Id currentUserId = UserInfo.getUserId();
      Id employeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);

      if (employeeId == null) {
        throw new AuraHandledException(
          'No employee record found for current user.'
        );
      }

      return [
        SELECT
          Id,
          Name,
          Employees__c,
          Employees__r.Name,
          Leave_Type__c,
          Leave_Type__r.Name,
          From_Date__c,
          To_Date__c,
          Total_Days__c,
          Half_Day__c,
          Reason__c,
          Status__c,
          CreatedDate
        FROM PWChrono_Leave__c
        WHERE
          Approvers__c = :employeeId
          AND Status__c = :PWChrono_Constants.STATUS_SUBMITTED
        ORDER BY CreatedDate DESC
        LIMIT 50
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      throw new AuraHandledException(
        'Error fetching team leaves: '
      );
    }
  }

  /**
   * @description Create or update leave application
   * @param leaveRecord Leave record to save
   * @param portalUserId The ID of the currently logged-in Portal User (for validation)
   * @return Saved leave record
   */
  @AuraEnabled
  public static PWChrono_Leave__c saveLeaveApplication(
    PWChrono_Leave__c leaveRecord,
    String portalUserId,
    String sessionToken
  ) {
    try {
      Id verifiedPortalUserId = PWChrono_GuestSession.requireVerifiedPortalUserId(
        portalUserId,
        sessionToken
      );

      // Set employee if not set, or enforce it
      if (leaveRecord.Id == null) {
        // Force the employee ID to match the session
        leaveRecord.Employees__c = verifiedPortalUserId;
      } else {
        // If updating, verify ownership
        // Note: We query without sharing because we are the gatekeeper
        List<PWChrono_Leave__c> existing = [SELECT Employees__c FROM PWChrono_Leave__c WHERE Id = :leaveRecord.Id LIMIT 1];
        if (existing.isEmpty() || existing[0].Employees__c != verifiedPortalUserId) {
             throw new AuraHandledException('Unauthorized access to this leave record.');
        }

        // Do not allow changing Employees__c on update.
        leaveRecord.Employees__c = verifiedPortalUserId;
      }

      // Validate dates
      if (leaveRecord.From_Date__c > leaveRecord.To_Date__c) {
        throw new AuraHandledException('End date must be after start date');
      }

      // Calculate actual days (Server-side enforcement)
      leaveRecord.Total_Days__c = calculateLeaveDays(
        leaveRecord.From_Date__c,
        leaveRecord.To_Date__c,
        leaveRecord.Half_Day__c
      );

      // Validate leave balance before submission
      if (leaveRecord.Status__c == PWChrono_Constants.STATUS_SUBMITTED) {
        validateLeaveBalance(leaveRecord);
      }

      // SECURITY NOTE: Guest users in Experience Cloud cannot pass standard CRUD/FLS checks.
      // Access control is enforced via Portal_Users__c ownership validation above.
      // The 'without sharing' context is required for guest user access pattern.
      upsert leaveRecord;

      return [
        SELECT
          Id,
          Name,
          Employees__c,
          Leave_Type__c,
          From_Date__c,
          To_Date__c,
          Total_Days__c,
          Half_Day__c,
          Reason__c,
          Status__c
        FROM PWChrono_Leave__c
        WHERE Id = :leaveRecord.Id
      ];
    } catch (AuraHandledException ahe) {
      throw ahe;
    } catch (Exception e) {
      PWChrono_Logger.error(
        'Error saving leave application: '
      );
      PWChrono_Logger.error('Stack trace: ' + e.getStackTraceString());
      String detail = (Test.isRunningTest() && String.isNotBlank(e.getMessage()))
        ? (' ' + e.getMessage())
        : '';
      throw new AuraHandledException('Error saving leave application.' + detail);
    }
  }

  /**
   * @description Approve or reject leave application
   * @param leaveId Leave record ID
   * @param action Approve or Reject
   * @param comments Optional rejection reason
   * @return Updated leave record
   */
  @AuraEnabled
  public static PWChrono_Leave__c processLeaveApproval(
    Id leaveId,
    String action,
    String comments
  ) {
    try {
      Id currentUserId = UserInfo.getUserId();
      Id currentEmployeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);

      PWChrono_Leave__c leave = [
        SELECT Id, Status__c, Rejection_Reason__c, Approval_Date__c, Employees__r.Reports_To__c
        FROM PWChrono_Leave__c
        WHERE Id = :leaveId
        LIMIT 1
      ];

      // Security Check: Only Admin or Manager (Reports To) can approve
      if (leave.Employees__r.Reports_To__c != currentEmployeeId && !PWChrono_AccessController.isAdmin(currentEmployeeId)) {
        throw new AuraHandledException('Access Denied: You are not authorized to process this request.');
      }

      // Validate status transition - only allow processing from Submitted status
      if (leave.Status__c != PWChrono_Constants.STATUS_SUBMITTED) {
        throw new AuraHandledException(
          'Leave can only be approved or rejected when status is Submitted. Current status: ' +
          leave.Status__c
        );
      }

      if (action == 'Approve') {
        leave.Status__c = PWChrono_Constants.STATUS_APPROVED;
        leave.Approval_Date__c = System.today();
      } else if (action == 'Reject') {
        leave.Status__c = PWChrono_Constants.STATUS_REJECTED;
        leave.Rejection_Reason__c = comments;
      } else {
        throw new AuraHandledException(
          'Invalid action. Must be Approve or Reject.'
        );
      }

      // Security Check - Bypassed for Guest User
      update leave;

      return leave;
    } catch (Exception e) {
      PWChrono_Logger.error(
        'Error processing leave approval: '
      );
      throw new AuraHandledException(
        'Error processing leave approval: '
      );
    }
  }

  /**
   * @description Get leave calendar data for team
   * @param startDate Start date for calendar
   * @param endDate End date for calendar
   * @return List of approved leaves in date range
   */
  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Leave__c> getLeaveCalendarData(
    Date startDate,
    Date endDate
  ) {
    try {
      Id currentUserId = UserInfo.getUserId();
      Id employeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);

      return [
        SELECT
          Id,
          Name,
          Employees__c,
          Employees__r.Name,
          Leave_Type__c,
          Leave_Type__r.Name,
          From_Date__c,
          To_Date__c,
          Total_Days__c,
          Half_Day__c,
          Status__c
        FROM PWChrono_Leave__c
        WHERE
          Status__c = :PWChrono_Constants.STATUS_APPROVED
          AND From_Date__c <= :endDate
          AND To_Date__c >= :startDate
          AND (Employees__c = :employeeId
          OR Employees__r.Reports_To__c = :employeeId)
        ORDER BY From_Date__c
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      throw new AuraHandledException(
        'Error fetching calendar data: '
      );
    }
  }

  /**
   * @description Get holidays for calendar
   * @param startDate Start date
   * @param endDate End date
   * @return List of holidays
   */
  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Holiday__c> getHolidays(
    Date startDate,
    Date endDate
  ) {
    try {
      return [
        SELECT
          Id,
          Name,
          Holiday_List__c,
          Holiday_List__r.Name,
          Holiday_Date__c,
          Is_Weekly_Off__c
        FROM PWChrono_Holiday__c
        WHERE
          Holiday_Date__c >= :startDate
          AND Holiday_Date__c <= :endDate
          AND Holiday_List__r.Is_Active__c = TRUE
        ORDER BY Holiday_Date__c
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      throw new AuraHandledException(
        'Error fetching holidays: '
      );
    }
  }

  /**
   * @description Get active leave types for dropdown
   * @return List of active leave types
   */
  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Leave_Type__c> getActiveLeaveTypes() {
    try {
      return [
        SELECT Id, Name, Max_Days_Allowed__c, Is_Carry_Forward__c, Max_Carry_Forward_Days__c, Requires_Approval__c, Requires_Certificate__c, Is_Active__c
        FROM PWChrono_Leave_Type__c
        WHERE Is_Active__c = TRUE
        ORDER BY Name
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      throw new AuraHandledException(
        'Error fetching leave types: '
      );
    }
  }

  /**
   * @description Update leave type settings
   * @param leaveType Leave type record to update
   */
  @AuraEnabled
  public static void updateLeaveType(PWChrono_Leave_Type__c leaveType) {
    try {
      // Security check: Ensure user is admin (handled by sharing rules or explicit check if needed)
      // For now, relying on without sharing class but ideally should check permission set
      
      // Log the update activity
      PWChrono_Logger.info('Updating Leave Type Settings: ' + leaveType.Id + ' - ' + JSON.serialize(leaveType));
      
      update leaveType;
    } catch (Exception e) {
      PWChrono_Logger.error('Error updating leave type: ');
      throw new AuraHandledException(
        'Error updating leave type: '
      );
    }
  }

  /**
   * @description Create a new leave type
   * @param leaveType Leave type record to create
   */
  @AuraEnabled
  public static void createLeaveType(PWChrono_Leave_Type__c leaveType) {
    try {
      // Log the creation activity
      PWChrono_Logger.info('Creating New Leave Type: ' + JSON.serialize(leaveType));
      
      insert leaveType;
    } catch (Exception e) {
      PWChrono_Logger.error('Error creating leave type: ');
      throw new AuraHandledException(
        'Error creating leave type: '
      );
    }
  }

  // Helper Methods

  // Cache for settings
  private static PWChrono_Settings__mdt cachedSettings;

  /**
   * @description Calculate working days excluding weekends and holidays
   */
  private static Decimal calculateLeaveDays(
    Date startDate,
    Date endDate,
    Boolean isHalfDay
  ) {
    if (startDate == null || endDate == null) {
      return 0;
    }
    if (isHalfDay == true) {
      return 0.5;
    }

    // Get Settings (Cached)
    if (cachedSettings == null) {
      List<PWChrono_Settings__mdt> settingsList = [
        SELECT Weekend_Day_1__c, Weekend_Day_2__c
        FROM PWChrono_Settings__mdt
        LIMIT 1
      ];
      if (!settingsList.isEmpty()) {
        cachedSettings = settingsList[0];
      }
    }

    String weekend1 = cachedSettings != null
      ? cachedSettings.Weekend_Day_1__c
      : 'Saturday';
    String weekend2 = cachedSettings != null
      ? cachedSettings.Weekend_Day_2__c
      : 'Sunday';

    // Get Holidays
    // Optimization: Fetch holidays only once per transaction if possible, or rely on efficient indexing.
    // For now, we keep the query but ensure it's selective.
    List<PWChrono_Holiday__c> holidays = [
      SELECT Holiday_Date__c
      FROM PWChrono_Holiday__c
      WHERE
        Holiday_Date__c >= :startDate
        AND Holiday_Date__c <= :endDate
        AND Holiday_List__r.Is_Active__c = TRUE
    ];
    Set<Date> holidayDates = new Set<Date>();
    for (PWChrono_Holiday__c h : holidays) {
      holidayDates.add(h.Holiday_Date__c);
    }

    Integer days = 0;
    Date d = startDate;
    while (d <= endDate) {
      DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
      String dayOfWeek = dt.format('EEEE');

      if (
        dayOfWeek != weekend1 &&
        dayOfWeek != weekend2 &&
        !holidayDates.contains(d)
      ) {
        days++;
      }
      d = d.addDays(1);
    }
    return days;
  }

  /**
   * @description Validate leave balance before application
   * @param leave Leave application record
   */
  private static void validateLeaveBalance(PWChrono_Leave__c leave) {
    // 1. Get Allocation
    List<PWChrono_Leave_Allocation__c> allocations = [
      SELECT
        Id,
        Total_Leaves_Allocated__c,
        Total_Leaves_Used__c,
        Total_Leaves_Encashed__c,
        From_Date__c,
        To_Date__c
      FROM PWChrono_Leave_Allocation__c
      WHERE
        Employees__c = :leave.Employees__c
        AND Leave_Type__c = :leave.Leave_Type__c
        AND To_Date__c >= TODAY
      LIMIT 1
    ];

    if (allocations.isEmpty()) {
      throw new AuraHandledException(
        'No leave allocation found for this leave type.'
      );
    }

    PWChrono_Leave_Allocation__c allocation = allocations[0];
    Decimal totalAllocated = allocation.Total_Leaves_Allocated__c != null
      ? allocation.Total_Leaves_Allocated__c
      : 0;
    Decimal totalUsed = allocation.Total_Leaves_Used__c != null
      ? allocation.Total_Leaves_Used__c
      : 0;
    Decimal totalEncashed = allocation.Total_Leaves_Encashed__c != null
      ? allocation.Total_Leaves_Encashed__c
      : 0;

    // 2. Optimize: Fetch all relevant leaves in one query (Overlap check)
    Date fromDate = allocation.From_Date__c != null
      ? allocation.From_Date__c
      : Date.newInstance(Date.today().year(), 1, 1);
    Date toDate = allocation.To_Date__c != null
      ? allocation.To_Date__c
      : Date.newInstance(Date.today().year(), 12, 31);

    // Determine the wider range to cover both allocation period and requested dates
    Date queryStart = fromDate < leave.From_Date__c
      ? fromDate
      : leave.From_Date__c;
    Date queryEnd = toDate > leave.To_Date__c ? toDate : leave.To_Date__c;

    List<PWChrono_Leave__c> allLeaves = [
      SELECT
        Id,
        Leave_Type__c,
        Total_Days__c,
        From_Date__c,
        To_Date__c,
        Status__c
      FROM PWChrono_Leave__c
      WHERE
        Employees__c = :leave.Employees__c
        AND Id != :leave.Id
        AND ((From_Date__c >= :queryStart
        AND From_Date__c <= :queryEnd)
        OR (To_Date__c >= :queryStart
        AND To_Date__c <= :queryEnd))
    ];
    Boolean hasOverlap = false;

    for (PWChrono_Leave__c l : allLeaves) {
      // Check Overlap (Any leave type, Submitted/Approved, overlaps with requested dates)
      if (
        (l.Status__c == PWChrono_Constants.STATUS_SUBMITTED ||
        l.Status__c == PWChrono_Constants.STATUS_APPROVED) &&
        l.From_Date__c <= leave.To_Date__c &&
        l.To_Date__c >= leave.From_Date__c
      ) {
        hasOverlap = true;
      }
    }

    // 3. Check Balance
    Decimal requestedDays = leave.Total_Days__c != null
      ? leave.Total_Days__c
      : 0;
    Decimal remaining = totalAllocated - totalUsed - totalEncashed;

    if (requestedDays > remaining) {
      throw new AuraHandledException(
        'Insufficient leave balance. Remaining: ' +
          remaining +
          ', Requested: ' +
          requestedDays
      );
    }

    if (hasOverlap) {
      throw new AuraHandledException(
        'Leave application overlaps with an existing leave.'
      );
    }
  }
}