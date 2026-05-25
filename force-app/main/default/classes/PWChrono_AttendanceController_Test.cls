/**
 * @description Tests for PWChrono_AttendanceController.
 *              Covers new framework methods and legacy method delegation.
 */
@IsTest
private class PWChrono_AttendanceController_Test {
  @TestSetup
  static void setup() {
    PWChrono_AttendanceTestDataFactory.setupStandardTestData();
  }

  // ─────────────────────── getMyAttendanceRequestList ──────────────────────

  @IsTest
  static void testGetMyAttendanceRequestList_returnsRequests() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Attendance_Request__c> result = PWChrono_AttendanceController.getMyAttendanceRequestList(
      'All',
      null,
      null,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should return a list');
    System.assert(result.size() >= 2, 'Should have at least 2 test requests');
  }

  @IsTest
  static void testGetMyAttendanceRequestList_filteredByStatus() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Attendance_Request__c> result = PWChrono_AttendanceController.getMyAttendanceRequestList(
      'Submitted',
      null,
      null,
      emp.Id,
      null
    );
    Test.stopTest();

    for (PWChrono_Attendance_Request__c req : result) {
      System.assertEquals(
        'Submitted',
        req.Status__c,
        'All results should be Submitted'
      );
    }
  }

  // ─────────────────────── getAttendanceRequestDetail ──────────────────────

  @IsTest
  static void testGetAttendanceRequestDetail_owner_succeeds() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Attendance_Request__c req = [
      SELECT Id
      FROM PWChrono_Attendance_Request__c
      WHERE Status__c = 'Submitted'
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_Attendance_Request__c result = PWChrono_AttendanceController.getAttendanceRequestDetail(
      req.Id,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertEquals(req.Id, result.Id, 'Should return correct record');
  }

  @IsTest
  static void testGetAttendanceRequestDetail_notFound_throwsException() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    try {
      PWChrono_AttendanceController.getAttendanceRequestDetail(
        '001000000000000AAA',
        emp.Id,
        null
      );
      System.assert(false, 'Should throw for missing record');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().length() > 0,
        'Should return a user-friendly error'
      );
    }
    Test.stopTest();
  }

  // ─────────────────────── submitAttendanceRequest ────────────────────────

  @IsTest
  static void testSubmitAttendanceRequest_succeeds() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_AttendanceValidator.AttendanceRequestDTO dto = PWChrono_AttendanceTestDataFactory.buildDTO(
      Date.today().addDays(-7),
      'Wrong Time'
    );

    Test.startTest();
    PWChrono_Attendance_Request__c result = PWChrono_AttendanceController.submitAttendanceRequest(
      dto,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertEquals('Submitted', result.Status__c, 'Should be Submitted');
  }

  // ─────────────────────── cancelAttendanceRequest ────────────────────────

  @IsTest
  static void testCancelAttendanceRequest_succeeds() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Attendance_Request__c req = [
      SELECT Id
      FROM PWChrono_Attendance_Request__c
      WHERE Status__c = 'Submitted'
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_Attendance_Request__c result = PWChrono_AttendanceController.cancelAttendanceRequest(
      req.Id,
      'Not needed',
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertEquals('Cancelled', result.Status__c, 'Should be Cancelled');
  }

  // ─────────────────────── getTeamAttendanceRequestsForApproval ────────────

  @IsTest
  static void testGetTeamAttendanceRequestsForApproval_returnsRequests() {
    Portal_Users__c mgr = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Manager'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Attendance_Request__c> result = PWChrono_AttendanceController.getTeamAttendanceRequestsForApproval(
      mgr.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should return a list');
    for (PWChrono_Attendance_Request__c req : result) {
      System.assertEquals(
        'Submitted',
        req.Status__c,
        'Only submitted should appear in approvals queue'
      );
    }
  }

  // ─────────────────────── processAttendanceCorrectionApproval ────────────

  @IsTest
  static void testProcessApproval_approve_succeeds() {
    Portal_Users__c mgr = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Manager'
      LIMIT 1
    ];
    PWChrono_Attendance_Request__c req = [
      SELECT Id
      FROM PWChrono_Attendance_Request__c
      WHERE Status__c = 'Submitted'
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_Attendance_Request__c result = PWChrono_AttendanceController.processAttendanceCorrectionApproval(
      req.Id,
      'Approve',
      'LGTM',
      mgr.Id,
      null
    );
    Test.stopTest();

    System.assertEquals('Approved', result.Status__c);
  }

  // ─────────────────────── getAttendanceDashboardSummary ──────────────────

  @IsTest
  static void testGetAttendanceDashboardSummary_returnsData() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    Date startDate = Date.today().addDays(-30);
    Date endDate = Date.today();

    Test.startTest();
    PWChrono_AttendanceService.AttendanceDashboardDTO result = PWChrono_AttendanceController.getAttendanceDashboardSummary(
      startDate,
      endDate,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result);
    System.assertNotEquals(null, result.recentRequests);
  }

  // ─────────────────────── getAttendanceTrackerData ────────────────────────

  @IsTest
  static void testGetAttendanceTrackerData_returnsData() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_AttendanceController.AttendanceDayWrapper> result = PWChrono_AttendanceController.getAttendanceTrackerData(
      Date.today().addDays(-7),
      Date.today(),
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result);
    System.assertEquals(
      8,
      result.size(),
      'Should return 8 days (addDays -7 to today inclusive)'
    );
  }

  // ─────────────────────── Legacy: saveAttendanceRequest ───────────────────

  @IsTest
  static void testSaveAttendanceRequest_legacy_succeeds() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Attendance_Request__c req = new PWChrono_Attendance_Request__c(
      Attendance_Date__c = Date.today().addDays(-8),
      Correction_Type__c = 'Check-Out Missing',
      Reason__c = 'Legacy test',
      Status__c = 'Submitted'
    );

    Test.startTest();
    PWChrono_Attendance_Request__c result = PWChrono_AttendanceController.saveAttendanceRequest(
      req,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result.Id);
    System.assertEquals(
      emp.Id,
      result.Employees__c,
      'Should enforce employee ownership'
    );
  }

  // ─────────────────────── getActiveShiftTypes ────────────────────────────

  @IsTest
  static void testGetActiveShiftTypes_returnsShifts() {
    Test.startTest();
    List<PWChrono_Shift_Type__c> result = PWChrono_AttendanceController.getActiveShiftTypes();
    Test.stopTest();

    System.assert(
      result.size() >= 1,
      'Should return at least the test shift type'
    );
  }
}
