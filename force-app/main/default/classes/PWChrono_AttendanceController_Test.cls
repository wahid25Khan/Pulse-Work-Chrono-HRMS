@isTest
private class PWChrono_AttendanceController_Test {
  @TestSetup
  static void makeData() {
    // Create User and Employee
    User testUser = PWChrono_TestDataFactory.createTestUser('EmployeeUser');
    PWChrono_TestDataFactory.assignPermissionSet(
      testUser.Id,
      'PWChrono_HR_Admin'
    );
    Portal_Users__c employee = PWChrono_TestDataFactory.createTestEmployee(
      testUser.Id
    );

    // Create Manager
    User managerUser = PWChrono_TestDataFactory.createTestUser('ManagerUser');
    PWChrono_TestDataFactory.assignPermissionSet(
      managerUser.Id,
      'PWChrono_HR_Admin'
    );
    Portal_Users__c manager = PWChrono_TestDataFactory.createTestEmployee(
      managerUser.Id
    );
    manager.Role__c = PWChrono_Constants.ROLE_MANAGER;
    update manager;

    employee.Reports_To__c = manager.Id;
    update employee;

    // Create Shift Type
    PWChrono_Shift_Type__c shiftType = new PWChrono_Shift_Type__c(
      Name = 'General Shift',
      Start_Time__c = Time.newInstance(9, 0, 0, 0),
      End_Time__c = Time.newInstance(18, 0, 0, 0),
      Working_Hours__c = 9,
      Grace_Period_Minutes__c = 15,
      Is_Active__c = true
    );
    insert shiftType;

    // Create Shift Assignment
    PWChrono_Shift_Assignment__c shiftAssignment = new PWChrono_Shift_Assignment__c(
      Employees__c = employee.Id,
      Shift_Type__c = shiftType.Id,
      From_Date__c = Date.today().addDays(-5),
      To_Date__c = Date.today().addDays(5),
      Status__c = PWChrono_Constants.STATUS_ACTIVE
    );
    insert shiftAssignment;

    // Create Attendance Request
    PWChrono_Attendance_Request__c request = new PWChrono_Attendance_Request__c(
      Employees__c = employee.Id,
      Attendance_Date__c = Date.today(),
      From_Time__c = Time.newInstance(9, 0, 0, 0),
      To_Time__c = Time.newInstance(18, 0, 0, 0),
      Reason__c = 'Regular Work',
      Status__c = PWChrono_Constants.STATUS_SUBMITTED,
      Approvers__c = manager.Id
    );
    insert request;

    // Create Holiday
    PWChrono_Holiday__c holiday = new PWChrono_Holiday__c(
      Name = 'Test Holiday',
      Holiday_Date__c = Date.today().addDays(1)
    );
    insert holiday;
  }

  @isTest
  static void testGetMyAttendanceRequests() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'EmployeeUser'
      LIMIT 1
    ];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Attendance_Request__c> requests = PWChrono_AttendanceController.getMyAttendanceRequests(
        'All',
        Date.today().addDays(-1),
        Date.today().addDays(1),
        null,
        null
      );
      Test.stopTest();

      System.assertEquals(
        1,
        requests.size(),
        'Should return 1 attendance request'
      );
    }
  }

  @isTest
  static void testGetMyShiftAssignments() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'EmployeeUser'
      LIMIT 1
    ];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Shift_Assignment__c> shifts = PWChrono_AttendanceController.getMyShiftAssignments(
        Date.today().addDays(-1),
        Date.today().addDays(1),
        null,
        null
      );
      Test.stopTest();

      System.assertEquals(1, shifts.size(), 'Should return 1 shift assignment');
    }
  }

  @isTest
  static void testGetTeamAttendanceForApproval() {
    // Find manager user (created in makeData, but need to query properly)
    // Since we created 2 users with same name in factory, we need to be careful.
    // Actually factory uses unique email/username but same lastname.
    // Let's query Portal_Users__c to find the manager's user.
    Portal_Users__c manager = [
      SELECT User__c
      FROM Portal_Users__c
      WHERE Role__c = :PWChrono_Constants.ROLE_MANAGER
      LIMIT 1
    ];
    User managerUser = [SELECT Id FROM User WHERE Id = :manager.User__c];

    System.runAs(managerUser) {
      Test.startTest();
      List<PWChrono_Attendance_Request__c> requests = PWChrono_AttendanceController.getTeamAttendanceForApproval();
      Test.stopTest();

      System.assertEquals(
        1,
        requests.size(),
        'Should return 1 pending request for approval'
      );
    }
  }

  @isTest
  static void testSaveAttendanceRequest() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'EmployeeUser'
      LIMIT 1
    ];

    System.runAs(testUser) {
      PWChrono_Attendance_Request__c newRequest = new PWChrono_Attendance_Request__c(
        Attendance_Date__c = Date.today().addDays(-1),
        From_Time__c = Time.newInstance(9, 0, 0, 0),
        To_Time__c = Time.newInstance(18, 0, 0, 0),
        Reason__c = 'Forgot to check in',
        Status__c = PWChrono_Constants.STATUS_DRAFT
      );

      Test.startTest();
      Portal_Users__c currentEmployee = [
        SELECT Id
        FROM Portal_Users__c
        WHERE User__c = :testUser.Id
        LIMIT 1
      ];
      PWChrono_Attendance_Request__c savedRequest = PWChrono_AttendanceController.saveAttendanceRequest(
        newRequest,
        currentEmployee.Id,
        null
      );
      Test.stopTest();

      System.assertNotEquals(null, savedRequest.Id, 'Request should be saved');
      System.assertEquals(
        PWChrono_Constants.STATUS_DRAFT,
        savedRequest.Status__c,
        'Status should be Draft'
      );
    }
  }

  @isTest
  static void testProcessAttendanceApproval() {
    Portal_Users__c manager = [
      SELECT User__c
      FROM Portal_Users__c
      WHERE Role__c = :PWChrono_Constants.ROLE_MANAGER
      LIMIT 1
    ];
    User managerUser = [SELECT Id FROM User WHERE Id = :manager.User__c];
    PWChrono_Attendance_Request__c request = [
      SELECT Id
      FROM PWChrono_Attendance_Request__c
      LIMIT 1
    ];

    System.runAs(managerUser) {
      Test.startTest();
      PWChrono_Attendance_Request__c processedRequest = PWChrono_AttendanceController.processAttendanceApproval(
        request.Id,
        'Approve',
        'Approved by Manager'
      );
      Test.stopTest();

      System.assertEquals(
        PWChrono_Constants.STATUS_APPROVED,
        processedRequest.Status__c,
        'Status should be Approved'
      );
    }
  }

  @isTest
  static void testGetActiveShiftTypes() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'EmployeeUser'
      LIMIT 1
    ];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Shift_Type__c> shifts = PWChrono_AttendanceController.getActiveShiftTypes();
      Test.stopTest();

      System.assert(!shifts.isEmpty(), 'Should return active shift types');
    }
  }

  @isTest
  static void testGetAttendanceTrackerData() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'EmployeeUser'
      LIMIT 1
    ];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_AttendanceController.AttendanceDayWrapper> data = PWChrono_AttendanceController.getAttendanceTrackerData(
        Date.today(),
        Date.today().addDays(2),
        null,
        null
      );
      Test.stopTest();

      System.assert(!data.isEmpty(), 'Should return tracker data');
      // Verify holiday
      Boolean foundHoliday = false;
      for (PWChrono_AttendanceController.AttendanceDayWrapper day : data) {
        if (day.status == 'Holiday') {
          foundHoliday = true;
          break;
        }
      }
      System.assert(foundHoliday, 'Should find the holiday');
    }
  }

  @isTest
  static void testGetTeamShiftAssignments() {
    Portal_Users__c manager = [
      SELECT User__c
      FROM Portal_Users__c
      WHERE Role__c = :PWChrono_Constants.ROLE_MANAGER
      LIMIT 1
    ];
    User managerUser = [SELECT Id FROM User WHERE Id = :manager.User__c];

    System.runAs(managerUser) {
      Test.startTest();
      List<PWChrono_Shift_Assignment__c> shifts = PWChrono_AttendanceController.getTeamShiftAssignments(
        Date.today().addDays(-5),
        Date.today().addDays(5)
      );
      Test.stopTest();

      System.assert(!shifts.isEmpty(), 'Should return team shifts');
    }
  }
}