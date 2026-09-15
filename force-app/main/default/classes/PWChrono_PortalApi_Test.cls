@IsTest
private with sharing class PWChrono_PortalApi_Test {
  @IsTest
  static void rejectsUnverifiedGuestBeforeAnyRead() {
    PWChrono_GuestSession.testUserTypeOverride = 'Guest';
    try {
      PWChrono_PortalApi.getAdminDashboardStats(null, null);
      System.assert(
        false,
        'Guest must prove a session before entering the data boundary'
      );
    } catch (AuraHandledException expected) {
      System.assert(expected.getMessage().contains('Session'));
    } finally {
      PWChrono_GuestSession.testUserTypeOverride = null;
    }
  }
  @IsTest
  static void employeeCannotUseAdministratorEndpoint() {
    Portal_Users__c employee = PWChrono_TestDataFactory.createPortalUser(
      'Portal API employee',
      'api-employee@example.com',
      'Employee'
    );
    employee.Session_Token__c = 'portal-api-test-token';
    employee.Session_Expires_At__c = System.now().addHours(1);
    update employee;
    PWChrono_GuestSession.testUserTypeOverride = 'Guest';
    try {
      PWChrono_PortalApi.getAdminDashboardStats(
        employee.Id,
        'portal-api-test-token'
      );
      System.assert(
        false,
        'A valid session does not grant administrator access'
      );
    } catch (AuraHandledException expected) {
      System.assert(expected.getMessage().contains('Access denied'));
    } finally {
      PWChrono_GuestSession.testUserTypeOverride = null;
    }
  }
  @IsTest
  static void rejectsUnverifiedGuestBeforeWrite() {
    PWChrono_GuestSession.testUserTypeOverride = 'Guest';
    try {
      PWChrono_PortalApi.saveProject(
        new Map<String, Object>{ 'Name' => 'Should not be written' },
        null,
        null
      );
      System.assert(false, 'Guest writes require session proof');
    } catch (AuraHandledException expected) {
      System.assertEquals(
        0,
        [
          SELECT COUNT()
          FROM PWChrono_Project__c
          WHERE Name = 'Should not be written'
        ]
      );
    } finally {
      PWChrono_GuestSession.testUserTypeOverride = null;
    }
  }
  @IsTest
  static void verifiedAdminReadsPrivateDataFromSharingCaller() {
    Portal_Users__c admin = PWChrono_TestDataFactory.createPortalUser(
      'Portal API administrator',
      'api-admin@example.com',
      'HR Admin'
    );
    admin.Session_Token__c = 'verified-admin-token';
    admin.Session_Expires_At__c = System.now().addHours(1);
    update admin;
    PWChrono_GuestSession.testUserTypeOverride = 'Guest';
    Test.startTest();
    PWChrono_AdminController.AdminDashboardDTO result = PWChrono_PortalApi.getAdminDashboardStats(
      admin.Id,
      'verified-admin-token'
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.totalEmployees,
      'Verified admin receives actual employee data'
    );
    PWChrono_GuestSession.testUserTypeOverride = null;
  }
}
