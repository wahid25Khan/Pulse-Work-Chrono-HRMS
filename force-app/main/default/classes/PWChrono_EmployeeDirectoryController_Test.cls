@isTest
private class PWChrono_EmployeeDirectoryController_Test {
  @testSetup
  static void setupData() {
    PWChrono_TestDataFactory.createTestUsers();

    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    PWChrono_TestDataFactory.assignPermissionSet(testUser.Id, 'PWChrono_Employee');

    Portal_Users__c employee = PWChrono_TestDataFactory.createTestEmployee(testUser.Id);
    employee.Department__c = 'Engineering';
    employee.Designation__c = 'Developer';
    update employee;

    Portal_Users__c secondEmployee = PWChrono_TestDataFactory.createPortalUser(
      'Directory Sample',
      'directory.sample@example.com',
      PWChrono_Constants.ROLE_EMPLOYEE
    );
    secondEmployee.Department__c = 'Operations';
    secondEmployee.Designation__c = 'Coordinator';
    update secondEmployee;
  }

  @isTest
  static void testSearchEmployees_BlankTermReturnsList() {
    Test.startTest();
    List<SObject> results = PWChrono_EmployeeDirectoryController.searchEmployees('');
    Test.stopTest();

    System.assertNotEquals(null, results, 'Search should return a list for blank term.');
    System.assert(results.size() > 0, 'Search should return available employees.');
  }

  @isTest
  static void testSearchEmployees_NamePrefixFilter() {
    Test.startTest();
    List<SObject> results = PWChrono_EmployeeDirectoryController.searchEmployees('Directory');
    Test.stopTest();

    System.assertNotEquals(null, results, 'Search should return a list.');
    System.assertEquals(1, results.size(), 'Prefix search should match expected directory sample record.');
  }

  @isTest
  static void testCheckRecordAccess_TrueForExistingRecord() {
    Id existingId = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Name = 'Directory Sample'
      LIMIT 1
    ].Id;

    Test.startTest();
    Boolean hasAccess = PWChrono_EmployeeDirectoryController.checkRecordAccess(existingId);
    Test.stopTest();

    System.assertEquals(true, hasAccess, 'Existing record should return true access result.');
  }

  @isTest
  static void testCheckRecordAccess_FalseForUnknownRecord() {
    Test.startTest();
    Boolean hasAccess = PWChrono_EmployeeDirectoryController.checkRecordAccess(
      (Id) 'a0A000000000001AAA'
    );
    Test.stopTest();

    System.assertEquals(false, hasAccess, 'Unknown record id should return false.');
  }
}
