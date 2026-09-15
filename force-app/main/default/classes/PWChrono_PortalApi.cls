/**
 * Portal entry boundary for manually authenticated Experience Cloud users.
 * Guest session proof is checked before entering system sharing context.
 * Delegated controllers retain feature, role, record-owner and transition checks.
 * This avoids using the site's Guest user's record visibility as the employee's
 * authorization policy. Never add an endpoint without auditing those checks.
 */
public without sharing class PWChrono_PortalApi {
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> getDashboardSummaryForPortal(
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_DashboardController.getDashboardSummaryForPortal(
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=true)
  public static PWChrono_AdminController.AdminDashboardDTO getAdminDashboardStats(
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AdminController.getAdminDashboardStats(
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<PWChrono_AdminController.ChartPoint> getEmployeesByDepartment(
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AdminController.getEmployeesByDepartment(
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=true)
  public static PWChrono_AdminController.AttendanceOverview getAttendanceOverview(
    Date forDate,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AdminController.getAttendanceOverview(
      forDate,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Project__c> getProjects(
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AdminController.getProjects(portalUserId, sessionToken);
  }

  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Job_Applicant__c> getJobApplicants(
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AdminController.getJobApplicants(
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<Account> getProjectClients(
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AdminController.getProjectClients(
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled
  public static Id saveProject(
    Map<String, Object> projectData,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AdminController.saveProject(
      projectData,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled
  public static Id uploadProjectLogo(
    Id projectId,
    String fileName,
    String base64Data,
    String contentType,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AdminController.uploadProjectLogo(
      projectId,
      fileName,
      base64Data,
      contentType,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled
  public static void deleteProject(
    Id projectId,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    PWChrono_AdminController.deleteProject(
      projectId,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=false)
  public static List<Leave__c> getTeamLeaves(
    String statusFilter,
    Date startDate,
    Date endDate,
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_LeaveController.getTeamLeaves(
      statusFilter,
      startDate,
      endDate,
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=false)
  public static List<Leave__c> getTeamLeavesForApproval(
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_LeaveController.getTeamLeavesForApproval(
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled
  public static Leave__c processLeaveApproval(
    Id leaveId,
    String action,
    String comments,
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_LeaveController.processLeaveApproval(
      leaveId,
      action,
      comments,
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Leave_Type__c createLeaveType(
    PWChrono_Leave_Type__c leaveType,
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_LeaveController.createLeaveType(
      leaveType,
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Leave_Type__c updateLeaveType(
    PWChrono_Leave_Type__c leaveType,
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_LeaveController.updateLeaveType(
      leaveType,
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=false)
  public static List<PWChrono_Attendance_Request__c> getTeamAttendanceForApproval(
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_AttendanceController.getTeamAttendanceForApproval(
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Attendance_Request__c processAttendanceApproval(
    Id requestId,
    String action,
    String comments,
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_AttendanceController.processAttendanceApproval(
      requestId,
      action,
      comments,
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=false)
  public static List<PWChrono_AttendanceController.AttendanceDayWrapper> getAttendanceTrackerDataForEmployee(
    Date startDate,
    Date endDate,
    String targetEmployeeId,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AttendanceController.getAttendanceTrackerDataForEmployee(
      startDate,
      endDate,
      targetEmployeeId,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=false)
  public static List<PWChrono_AttendanceController.AttendanceAdminRow> getAttendanceAdminRows(
    Date dateFilter,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AttendanceController.getAttendanceAdminRows(
      dateFilter,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=false)
  public static List<PWChrono_Shift_Assignment__c> getMyShiftAssignments(
    Date startDate,
    Date endDate,
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_AttendanceController.getMyShiftAssignments(
      startDate,
      endDate,
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Attendance_Request__c saveAttendanceRequest(
    PWChrono_Attendance_Request__c attendanceRequest,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AttendanceController.saveAttendanceRequest(
      attendanceRequest,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Shift_Type__c createShiftType(
    PWChrono_Shift_Type__c shiftType,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AttendanceController.createShiftType(
      shiftType,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Shift_Type__c updateShiftType(
    PWChrono_Shift_Type__c shiftType,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_AttendanceController.updateShiftType(
      shiftType,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Goal__c> getMyGoals(
    String statusFilter,
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_PerformanceController.getMyGoals(
      statusFilter,
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Goal__c saveGoal(
    PWChrono_Goal__c goal,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_PerformanceController.saveGoal(
      goal,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Goal__c updateGoalProgress(
    Id goalId,
    Decimal progressPercentage,
    String status,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_PerformanceController.updateGoalProgress(
      goalId,
      progressPercentage,
      status,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Appraisal__c> getMyAppraisals(
    String statusFilter,
    String employeeId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) employeeId,
      sessionToken
    );
    return PWChrono_PerformanceController.getMyAppraisals(
      statusFilter,
      employeeId,
      sessionToken
    );
  }

  @AuraEnabled
  public static PWChrono_Appraisal__c saveAppraisal(
    PWChrono_Appraisal__c appraisal,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_PerformanceController.saveAppraisal(
      appraisal,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Training_Attendance__c> getMyRegistrations(
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    return PWChrono_TrainingController.getMyRegistrations(
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled
  public static void registerForTraining(
    Id eventId,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    PWChrono_TrainingController.registerForTraining(
      eventId,
      portalUserId,
      sessionToken
    );
  }

  @AuraEnabled
  public static void cancelRegistration(
    Id attendanceId,
    String portalUserId,
    String sessionToken
  ) {
    PWChrono_GuestSession.requireVerifiedPortalUserId(
      (String) portalUserId,
      sessionToken
    );
    PWChrono_TrainingController.cancelRegistration(
      attendanceId,
      portalUserId,
      sessionToken
    );
  }
}
