/**
 * @description Controller for Attendance Management LWC Components
 * @author PWChrono Team
 */
public inherited sharing class PWChrono_AttendanceController {
  private static Boolean hasFeature(String accessFeatures, String featureName) {
    if (String.isBlank(accessFeatures) || String.isBlank(featureName)) {
      return false;
    }
    for (String part : accessFeatures.split(';')) {
      if (part != null && part.trim() == featureName) {
        return true;
      }
    }
    return false;
  }

  private static void requireAttendanceAdminAccessForGuest(
    String portalUserId,
    String sessionToken
  ) {
    Id verifiedPortalUserId = PWChrono_GuestSession.requireVerifiedPortalUserId(
      portalUserId,
      sessionToken
    );

    Portal_Users__c portalUser = [
      SELECT Id, Is_Active__c, Role__c, Access_Features__c
      FROM Portal_Users__c
      WHERE Id = :verifiedPortalUserId
      LIMIT 1
    ];

    if (portalUser == null || portalUser.Is_Active__c != true) {
      throw new AuraHandledException('Unauthorized.');
    }

    Boolean isAdminRole =
      portalUser.Role__c == 'HR Admin' ||
      portalUser.Role__c == 'System Admin';
    if (
      !isAdminRole &&
      !hasFeature(portalUser.Access_Features__c, 'Admin Settings')
    ) {
      throw new AuraHandledException('Access denied.');
    }
  }
  /**
   * @description Get attendance requests for current employee
   * @param statusFilter Status filter
   * @param startDate Start date filter
   * @param endDate End date filter
   * @param employeeId Optional employee ID (Portal_Users__c). If null, uses current user's employee record.
   * @return List of attendance requests
   */
  @AuraEnabled(cacheable=true)
  @SuppressWarnings('PMD.ApexSOQLInjection')
  public static List<PWChrono_Attendance_Request__c> getMyAttendanceRequests(
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
        Id currentEmployeeId = PWChrono_Utils.getCurrentEmployeeId(
          currentUserId
        );
        if (currentEmployeeId == null) {
          throw new AuraHandledException(
            'No employee record found for current user.'
          );
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
        'SELECT Id, Name, Employees__c, Attendance_Date__c, ' +
        'From_Time__c, To_Time__c, Reason__c, Status__c, ' +
        'Approvers__c, Approvers__r.Name, CreatedDate ' +
        'FROM PWChrono_Attendance_Request__c ' +
        'WHERE Employees__c = :targetEmployeeId ';

      if (statusFilter != null && statusFilter != 'All') {
        query += 'AND Status__c = :statusFilter ';
      }

      if (startDate != null) {
        query += 'AND Attendance_Date__c >= :startDate ';
      }

      if (endDate != null) {
        query += 'AND Attendance_Date__c <= :endDate ';
      }

      Integer queryLimit = PWChrono_Constants.DEFAULT_QUERY_LIMIT;
      query += ' ORDER BY Attendance_Date__c DESC LIMIT :queryLimit';

      return Database.query(query);
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error fetching attendance requests: '
      );
      ahe.setMessage('Error fetching attendance requests: ');
      throw ahe;
    }
  }

  /**
   * @description Get current employee's shift assignments
   * @param startDate Start date
   * @param endDate End date
   * @return List of shift assignments
   */
  @AuraEnabled(cacheable=false)
  public static List<PWChrono_Shift_Assignment__c> getMyShiftAssignments(
    Date startDate,
    Date endDate,
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
        Id currentUserId = UserInfo.getUserId();
        targetEmployeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);
      }

      if (targetEmployeeId == null) {
        throw new AuraHandledException(
          'No employee record found for current user.'
        );
      }

      return [
        SELECT
          Id,
          Name,
          Employees__c,
          Shift_Type__c,
          Shift_Type__r.Name,
          Shift_Type__r.Start_Time__c,
          Shift_Type__r.End_Time__c,
          Shift_Type__r.Working_Hours__c,
          From_Date__c,
          To_Date__c,
          Status__c
        FROM PWChrono_Shift_Assignment__c
        WHERE
          Employees__c = :targetEmployeeId
          AND From_Date__c <= :endDate
          AND To_Date__c >= :startDate
        ORDER BY From_Date__c
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error fetching shift assignments: '
      );
      ahe.setMessage('Error fetching shift assignments: ');
      throw ahe;
    }
  }

  /**
   * @description Get team attendance requests for approval
   * @return List of pending attendance requests
   */
  @AuraEnabled(cacheable=false)
  public static List<PWChrono_Attendance_Request__c> getTeamAttendanceForApproval() {
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
          Attendance_Date__c,
          From_Time__c,
          To_Time__c,
          Reason__c,
          Status__c,
          CreatedDate
        FROM PWChrono_Attendance_Request__c
        WHERE
          Approvers__c = :employeeId
          AND Status__c = :PWChrono_Constants.STATUS_SUBMITTED
        ORDER BY CreatedDate DESC
        LIMIT :PWChrono_Constants.DASHBOARD_QUERY_LIMIT
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error fetching team attendance: '
      );
      ahe.setMessage('Error fetching team attendance: ');
      throw ahe;
    }
  }

  /**
   * @description Save attendance request
   * @param attendanceRequest Attendance request record
   * @return Saved attendance request
   */
  @AuraEnabled
  public static PWChrono_Attendance_Request__c saveAttendanceRequest(
    PWChrono_Attendance_Request__c attendanceRequest,
    String portalUserId,
    String sessionToken
  ) {
    try {
      Id verifiedPortalUserId = PWChrono_GuestSession.requireVerifiedPortalUserId(
        portalUserId,
        sessionToken
      );

      // Always enforce ownership.
      if (attendanceRequest.Id == null) {
        attendanceRequest.Employees__c = verifiedPortalUserId;
      } else {
        List<PWChrono_Attendance_Request__c> existing = [
          SELECT Employees__c
          FROM PWChrono_Attendance_Request__c
          WHERE Id = :attendanceRequest.Id
          LIMIT 1
        ];
        if (
          existing.isEmpty() || existing[0].Employees__c != verifiedPortalUserId
        ) {
          throw new AuraHandledException(
            'Unauthorized access to this attendance record.'
          );
        }
        // Do not allow changing Employees__c on update.
        attendanceRequest.Employees__c = verifiedPortalUserId;
      }

      if (attendanceRequest.Id == null) {
        insert attendanceRequest;
      } else {
        update attendanceRequest;
      }

      return [
        SELECT
          Id,
          Name,
          Employees__c,
          Attendance_Date__c,
          From_Time__c,
          To_Time__c,
          Reason__c,
          Status__c
        FROM PWChrono_Attendance_Request__c
        WHERE Id = :attendanceRequest.Id
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error saving attendance request: '
      );
      ahe.setMessage('Error saving attendance request: ');
      throw ahe;
    }
  }

  /**
   * @description Process attendance approval
   * @param requestId Attendance request ID
   * @param action Approve or Reject
   * @param comments Optional rejection reason
   * @return Updated attendance request
   */
  @AuraEnabled
  public static PWChrono_Attendance_Request__c processAttendanceApproval(
    Id requestId,
    String action,
    String comments
  ) {
    try {
      Id currentUserId = UserInfo.getUserId();
      Id currentEmployeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);

      List<PWChrono_Attendance_Request__c> requests = [
        SELECT Id, Status__c, Approvers__c
        FROM PWChrono_Attendance_Request__c
        WHERE Id = :requestId
        LIMIT 1
      ];

      if (requests.isEmpty()) {
        throw new AuraHandledException('Attendance request not found.');
      }
      PWChrono_Attendance_Request__c request = requests[0];

      // Security Check: Only Admin or Assigned Approver can approve
      if (
        request.Approvers__c != currentEmployeeId &&
        !PWChrono_AccessController.isAdmin(currentEmployeeId)
      ) {
        throw new AuraHandledException(
          'Access Denied: You are not authorized to process this request.'
        );
      }

      if (action == 'Approve') {
        request.Status__c = PWChrono_Constants.STATUS_APPROVED;
      } else if (action == 'Reject') {
        request.Status__c = PWChrono_Constants.STATUS_REJECTED;
      }
      update request;

      return request;
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error processing attendance approval: '
      );
      ahe.setMessage('Error processing attendance approval: ');
      throw ahe;
    }
  }

  /**
   * @description Get active shift types
   * @return List of shift types
   */
  @AuraEnabled(cacheable=false)
  public static List<PWChrono_Shift_Type__c> getActiveShiftTypes() {
    try {
      return [
        SELECT
          Id,
          Name,
          Start_Time__c,
          End_Time__c,
          Working_Hours__c,
          Grace_Period_Minutes__c
        FROM PWChrono_Shift_Type__c
        WHERE Is_Active__c = TRUE
        ORDER BY Name
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error fetching shift types: '
      );
      ahe.setMessage('Error fetching shift types: ');
      throw ahe;
    }
  }

  /**
   * @description Wrapper class for daily attendance summary
   */
  public class AttendanceDayWrapper {
    @AuraEnabled
    public Date attendanceDate;
    @AuraEnabled
    public String dayName;
    @AuraEnabled
    public String status; // Present, Absent, Leave, Holiday, Weekend, Future
    @AuraEnabled
    public String shiftName;
    @AuraEnabled
    public Time shiftStart;
    @AuraEnabled
    public Time shiftEnd;
    @AuraEnabled
    public Time checkIn;
    @AuraEnabled
    public Time checkOut;
    @AuraEnabled
    public Id attendanceRequestId;
    @AuraEnabled
    public String leaveType;
    @AuraEnabled
    public String holidayName;
    @AuraEnabled
    public Boolean isLate;
    @AuraEnabled
    public Boolean isEarlyLeave;
  }

  /**
   * @description Get comprehensive attendance data for a date range
   * @param startDate Start date
   * @param endDate End date
   * @param employeeId Optional employee ID (Portal_Users__c). If null, uses current user's employee record.
   * @return List of daily attendance wrappers
   */
  @AuraEnabled(cacheable=false)
  public static List<AttendanceDayWrapper> getAttendanceTrackerData(
    Date startDate,
    Date endDate,
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
      } else {
        targetEmployeeId = (String.isNotBlank(employeeId))
          ? (Id) employeeId
          : PWChrono_Utils.getCurrentEmployeeId(UserInfo.getUserId());
      }

      return getAttendanceTrackerDataCore(
        startDate,
        endDate,
        (String) targetEmployeeId
      );
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error fetching attendance tracker data: '
      );
      ahe.setMessage('Error fetching attendance tracker data: ');
      throw ahe;
    }
  }

  private static List<AttendanceDayWrapper> getAttendanceTrackerDataCore(
    Date startDate,
    Date endDate,
    String employeeId
  ) {
    Id targetEmployeeId;
    if (String.isNotBlank(employeeId)) {
      targetEmployeeId = (Id) employeeId;
    } else {
      targetEmployeeId = PWChrono_Utils.getCurrentEmployeeId(
        UserInfo.getUserId()
      );
    }

    if (targetEmployeeId == null) {
      throw new AuraHandledException(
        'No employee record found for current user.'
      );
    }

    checkTrackerPermissions();

    List<PWChrono_Shift_Assignment__c> shifts = fetchShifts(
      targetEmployeeId,
      startDate,
      endDate
    );
    Map<Date, PWChrono_Attendance_Request__c> requestsMap = fetchAttendanceRequestsMap(
      targetEmployeeId,
      startDate,
      endDate
    );
    List<PWChrono_Leave__c> leaves = fetchLeaves(
      targetEmployeeId,
      startDate,
      endDate
    );
    Map<Date, String> holidaysMap = fetchHolidaysMap(startDate, endDate);

    List<AttendanceDayWrapper> result = new List<AttendanceDayWrapper>();
    Date currentDate = startDate;

    while (currentDate <= endDate) {
      result.add(
        createDayWrapper(currentDate, shifts, requestsMap, leaves, holidaysMap)
      );
      currentDate = currentDate.addDays(1);
    }

    return result;
  }

  private static void checkTrackerPermissions() {
    return;
  }

  private static List<PWChrono_Shift_Assignment__c> fetchShifts(
    Id employeeId,
    Date startDate,
    Date endDate
  ) {
    return [
      SELECT
        Id,
        Shift_Type__r.Name,
        Shift_Type__r.Start_Time__c,
        Shift_Type__r.End_Time__c,
        From_Date__c,
        To_Date__c
      FROM PWChrono_Shift_Assignment__c
      WHERE
        Employees__c = :employeeId
        AND From_Date__c <= :endDate
        AND To_Date__c >= :startDate
    ];
  }

  private static Map<Date, PWChrono_Attendance_Request__c> fetchAttendanceRequestsMap(
    Id employeeId,
    Date startDate,
    Date endDate
  ) {
    Map<Date, PWChrono_Attendance_Request__c> requestsMap = new Map<Date, PWChrono_Attendance_Request__c>();
    for (PWChrono_Attendance_Request__c req : [
      SELECT Attendance_Date__c, From_Time__c, To_Time__c, Status__c
      FROM PWChrono_Attendance_Request__c
      WHERE
        Employees__c = :employeeId
        AND Attendance_Date__c >= :startDate
        AND Attendance_Date__c <= :endDate
        AND Status__c IN (
          :PWChrono_Constants.STATUS_APPROVED,
          :PWChrono_Constants.STATUS_SUBMITTED
        )
    ]) {
      requestsMap.put(req.Attendance_Date__c, req);
    }
    return requestsMap;
  }

  private static List<PWChrono_Leave__c> fetchLeaves(
    Id employeeId,
    Date startDate,
    Date endDate
  ) {
    return [
      SELECT From_Date__c, To_Date__c, Leave_Type__r.Name
      FROM PWChrono_Leave__c
      WHERE
        Employees__c = :employeeId
        AND Status__c = :PWChrono_Constants.STATUS_APPROVED
        AND From_Date__c <= :endDate
        AND To_Date__c >= :startDate
    ];
  }

  private static Map<Date, String> fetchHolidaysMap(
    Date startDate,
    Date endDate
  ) {
    Map<Date, String> holidaysMap = new Map<Date, String>();
    for (PWChrono_Holiday__c holiday : [
      SELECT Holiday_Date__c, Name
      FROM PWChrono_Holiday__c
      WHERE Holiday_Date__c >= :startDate AND Holiday_Date__c <= :endDate
    ]) {
      holidaysMap.put(holiday.Holiday_Date__c, holiday.Name);
    }
    return holidaysMap;
  }

  private static AttendanceDayWrapper createDayWrapper(
    Date currentDate,
    List<PWChrono_Shift_Assignment__c> shifts,
    Map<Date, PWChrono_Attendance_Request__c> requestsMap,
    List<PWChrono_Leave__c> leaves,
    Map<Date, String> holidaysMap
  ) {
    AttendanceDayWrapper day = new AttendanceDayWrapper();
    day.attendanceDate = currentDate;
    DateTime dt = DateTime.newInstance(
      currentDate.year(),
      currentDate.month(),
      currentDate.day()
    );
    day.dayName = dt.format('EEEE');
    day.status = (currentDate > Date.today()) ? 'Future' : 'Absent';

    applyShift(day, currentDate, shifts);
    applyHoliday(day, currentDate, holidaysMap);
    applyLeave(day, currentDate, leaves);
    applyAttendanceRequest(day, currentDate, requestsMap);
    applyWeekend(day);

    return day;
  }

  private static void applyShift(
    AttendanceDayWrapper day,
    Date currentDate,
    List<PWChrono_Shift_Assignment__c> shifts
  ) {
    for (PWChrono_Shift_Assignment__c shift : shifts) {
      if (
        currentDate >= shift.From_Date__c &&
        currentDate <= shift.To_Date__c
      ) {
        day.shiftName = shift.Shift_Type__r.Name;
        day.shiftStart = shift.Shift_Type__r.Start_Time__c;
        day.shiftEnd = shift.Shift_Type__r.End_Time__c;
        break;
      }
    }
  }

  private static void applyHoliday(
    AttendanceDayWrapper day,
    Date currentDate,
    Map<Date, String> holidaysMap
  ) {
    if (holidaysMap.containsKey(currentDate)) {
      day.status = 'Holiday';
      day.holidayName = holidaysMap.get(currentDate);
    }
  }

  private static void applyLeave(
    AttendanceDayWrapper day,
    Date currentDate,
    List<PWChrono_Leave__c> leaves
  ) {
    for (PWChrono_Leave__c leave : leaves) {
      if (
        currentDate >= leave.From_Date__c &&
        currentDate <= leave.To_Date__c
      ) {
        day.status = 'Leave';
        day.leaveType = leave.Leave_Type__r.Name;
        break;
      }
    }
  }

  private static void applyAttendanceRequest(
    AttendanceDayWrapper day,
    Date currentDate,
    Map<Date, PWChrono_Attendance_Request__c> requestsMap
  ) {
    if (requestsMap.containsKey(currentDate)) {
      PWChrono_Attendance_Request__c req = requestsMap.get(currentDate);
      day.attendanceRequestId = req.Id;
      day.checkIn = req.From_Time__c;
      day.checkOut = req.To_Time__c;
      day.status = 'Present';

      if (day.shiftStart != null && req.From_Time__c > day.shiftStart) {
        day.isLate = true;
      }
      if (day.shiftEnd != null && req.To_Time__c < day.shiftEnd) {
        day.isEarlyLeave = true;
      }
    }
  }

  private static void applyWeekend(AttendanceDayWrapper day) {
    if (day.dayName == 'Saturday' || day.dayName == 'Sunday') {
      if (day.status == 'Absent') {
        day.status = 'Weekend';
      }
    }
  }

  /**
   * @description Get team shift assignments
   * @param startDate Start date
   * @param endDate End date
   * @return List of shift assignments for team
   */
  @AuraEnabled(cacheable=false)
  public static List<PWChrono_Shift_Assignment__c> getTeamShiftAssignments(
    Date startDate,
    Date endDate
  ) {
    try {
      Id currentUserId = UserInfo.getUserId();
      Id employeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);

      if (employeeId == null) {
        throw new AuraHandledException(
          'No employee record found for current user.'
        );
      }

      // Find employees reporting to current user
      List<Portal_Users__c> teamMembers = [
        SELECT Id
        FROM Portal_Users__c
        WHERE Reports_To__c = :employeeId
      ];

      Set<Id> teamIds = new Set<Id>();
      for (Portal_Users__c emp : teamMembers) {
        teamIds.add(emp.Id);
      }

      return [
        SELECT
          Id,
          Name,
          Employees__c,
          Employees__r.Name,
          Shift_Type__c,
          Shift_Type__r.Name,
          Shift_Type__r.Start_Time__c,
          Shift_Type__r.End_Time__c,
          From_Date__c,
          To_Date__c,
          Status__c
        FROM PWChrono_Shift_Assignment__c
        WHERE
          Employees__c IN :teamIds
          AND From_Date__c <= :endDate
          AND To_Date__c >= :startDate
        ORDER BY Employees__r.Name, From_Date__c
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error fetching team shifts: '
      );
      ahe.setMessage('Error fetching team shifts: ');
      throw ahe;
    }
  }

  /**
   * @description Get all attendance records for admin view
   * @param dateFilter Optional date filter
   * @return List of attendance records
   */
  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Attendance_Request__c> getAllAttendance(
    Date dateFilter,
    String portalUserId,
    String sessionToken
  ) {
    try {
      if (UserInfo.getUserType() == 'Guest') {
        requireAttendanceAdminAccessForGuest(portalUserId, sessionToken);
      }
      return getAllAttendanceCore(dateFilter);
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      throw new AuraHandledException('Error fetching all attendance: ');
    }
  }

  private static List<PWChrono_Attendance_Request__c> getAllAttendanceCore(
    Date dateFilter
  ) {
    String query =
      'SELECT Id, Name, Employees__c, Employees__r.Name, Employees__r.Role__c, ' +
      'Attendance_Date__c, From_Time__c, To_Time__c, Status__c, Reason__c ' +
      'FROM PWChrono_Attendance_Request__c ';

    if (dateFilter != null) {
      query += 'WHERE Attendance_Date__c = :dateFilter ';
    } else {
      Date today = Date.today();
      query += 'WHERE Attendance_Date__c = :today ';
    }

    query += 'ORDER BY Employees__r.Name ASC';
    return Database.query(query);
  }

  /**
   * @description Create a new shift type
   * @param shiftType Shift type record
   * @return Created shift type
   */
  @AuraEnabled
  public static PWChrono_Shift_Type__c createShiftType(
    PWChrono_Shift_Type__c shiftType,
    String portalUserId,
    String sessionToken
  ) {
    try {
      if (UserInfo.getUserType() == 'Guest') {
        requireAttendanceAdminAccessForGuest(portalUserId, sessionToken);
      }
      insert shiftType;
      return shiftType;
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      throw new AuraHandledException('Error creating shift type: ');
    }
  }

  /**
   * @description Update an existing shift type
   * @param shiftType Shift type record
   * @return Updated shift type
   */
  @AuraEnabled
  public static PWChrono_Shift_Type__c updateShiftType(
    PWChrono_Shift_Type__c shiftType,
    String portalUserId,
    String sessionToken
  ) {
    try {
      if (UserInfo.getUserType() == 'Guest') {
        requireAttendanceAdminAccessForGuest(portalUserId, sessionToken);
      }
      update shiftType;
      return shiftType;
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      throw new AuraHandledException('Error updating shift type: ');
    }
  }

  // Helper Methods
}
