@isTest
private class PWChrono_LeaveController_Test {
  @TestSetup
  static void makeData() {
    // Create User and Employee
    PWChrono_TestDataFactory.createTestUsers();
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    PWChrono_TestDataFactory.assignPermissionSet(
      testUser.Id,
      'PWChrono_HR_Admin'
    );
    Portal_Users__c employee = PWChrono_TestDataFactory.createTestEmployee(
      testUser.Id
    );

    // Create Manager
    User managerUser = [SELECT Id FROM User WHERE Alias = 'admin' LIMIT 1];
    PWChrono_TestDataFactory.assignPermissionSet(
      managerUser.Id,
      'PWChrono_HR_Admin'
    );
    Portal_Users__c manager = PWChrono_TestDataFactory.createPortalUser(
      'Manager User',
      'manager@example.com',
      PWChrono_Constants.ROLE_MANAGER
    );
    manager.User__c = managerUser.Id;
    update manager;

    employee.Reports_To__c = manager.Id;
    update employee;

    // Create Leave Type
    PWChrono_Leave_Type__c leaveType = new PWChrono_Leave_Type__c(
      Name = 'Annual Leave',
      Max_Days_Allowed__c = 20,
      Is_Active__c = true
    );
    insert leaveType;

    // Create Leave Allocation
    PWChrono_Leave_Allocation__c allocation = new PWChrono_Leave_Allocation__c(
      Employees__c = employee.Id,
      Leave_Type__c = leaveType.Id,
      Total_Leaves_Allocated__c = 20,
      From_Date__c = Date.newInstance(Date.today().year(), 1, 1),
      To_Date__c = Date.newInstance(Date.today().year(), 12, 31)
    );
    insert allocation;

    // Create Leave Request
    PWChrono_Leave__c leave = new PWChrono_Leave__c(
      Employees__c = employee.Id,
      Leave_Type__c = leaveType.Id,
      From_Date__c = Date.today().addDays(5),
      To_Date__c = Date.today().addDays(6),
      Reason__c = 'Vacation',
      Status__c = PWChrono_Constants.STATUS_SUBMITTED,
      Approvers__c = manager.Id
    );
    insert leave;
  }

  @isTest
  static void testGetMyLeaveBalances() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_LeaveBalanceService.LeaveBalanceWrapper> balances = PWChrono_LeaveController.getMyLeaveBalance(
        null,
        null
      );
      Test.stopTest();

      System.assertEquals(1, balances.size(), 'Should return 1 leave balance');
    }
  }

  @isTest
  static void testGetMyLeaveHistory() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Leave__c> history = PWChrono_LeaveController.getMyLeaves(
        'All',
        null,
        null,
        null,
        null
      );
      Test.stopTest();

      System.assertEquals(
        1,
        history.size(),
        'Should return 1 leave history record'
      );
    }
  }

  @isTest
  static void testGetTeamLeavesForApproval() {
    User managerUser = [SELECT Id FROM User WHERE Alias = 'admin' LIMIT 1];

    System.runAs(managerUser) {
      Test.startTest();
      List<PWChrono_Leave__c> leaves = PWChrono_LeaveController.getTeamLeavesForApproval();
      Test.stopTest();

      System.assertEquals(
        1,
        leaves.size(),
        'Should return 1 pending leave for approval'
      );
    }
  }

  @isTest
  static void testSaveLeaveApplication() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    PWChrono_Leave_Type__c leaveType = [
      SELECT Id
      FROM PWChrono_Leave_Type__c
      LIMIT 1
    ];

    System.runAs(testUser) {
      PWChrono_Leave__c newLeave = new PWChrono_Leave__c(
        Leave_Type__c = leaveType.Id,
        From_Date__c = Date.today().addDays(10),
        To_Date__c = Date.today().addDays(11),
        Reason__c = 'Sick Leave',
        Status__c = PWChrono_Constants.STATUS_DRAFT
      );

      Test.startTest();
      // Get the employee ID for the current user
      Portal_Users__c currentEmployee = [
        SELECT Id
        FROM Portal_Users__c
        WHERE User__c = :testUser.Id
        LIMIT 1
      ];
      PWChrono_Leave__c savedLeave = PWChrono_LeaveController.saveLeaveApplication(
        newLeave,
        currentEmployee.Id,
        null
      );
      Test.stopTest();

      System.assertNotEquals(null, savedLeave.Id, 'Leave should be saved');
      System.assertEquals(
        PWChrono_Constants.STATUS_DRAFT,
        savedLeave.Status__c,
        'Status should be Draft'
      );
    }
  }

  @isTest
  static void testProcessLeaveApproval() {
    User managerUser = [SELECT Id FROM User WHERE Alias = 'admin' LIMIT 1];
    PWChrono_Leave__c leave = [SELECT Id FROM PWChrono_Leave__c LIMIT 1];

    System.runAs(managerUser) {
      Test.startTest();
      PWChrono_Leave__c processedLeave = PWChrono_LeaveController.processLeaveApproval(
        leave.Id,
        'Approve',
        'Approved by Manager'
      );
      Test.stopTest();

      System.assertEquals(
        PWChrono_Constants.STATUS_APPROVED,
        processedLeave.Status__c,
        'Status should be Approved'
      );
    }
  }

  @isTest
  static void testGetActiveLeaveTypes() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Leave_Type__c> types = PWChrono_LeaveController.getActiveLeaveTypes();
      Test.stopTest();

      System.assert(!types.isEmpty(), 'Should return active leave types');
    }
  }
}
