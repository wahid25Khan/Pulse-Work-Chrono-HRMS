@isTest
private class PWChrono_GuestSession_Test {
  @testSetup
  static void setupData() {
    PWChrono_TestDataFactory.createTestUsers();
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

    System.runAs(testUser) {
      Portal_Users__c employee = PWChrono_TestDataFactory.createTestEmployee(
        testUser.Id
      );
      employee.Session_Token__c = 'valid_token';
      employee.Session_Expires_At__c = System.now().addHours(1);
      update employee;
    }
  }

  @isTest
  static void testRequireVerifiedPortalUserId_NonGuestProvidedPortalId() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    Portal_Users__c employee = [SELECT Id FROM Portal_Users__c LIMIT 1];

    System.runAs(testUser) {
      Id result = PWChrono_GuestSession.requireVerifiedPortalUserId(
        String.valueOf(employee.Id),
        null
      );
      System.assertEquals(employee.Id, result, 'Should return provided portal user Id for non-guest context.');
    }
  }

  @isTest
  static void testRequireVerifiedPortalUserId_NonGuestInvalidPortalId() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

    System.runAs(testUser) {
      try {
        PWChrono_GuestSession.requireVerifiedPortalUserId('invalid_id', null);
        System.assert(false, 'Expected invalid portal user Id to throw an exception.');
      } catch (AuraHandledException e) {
        System.assertEquals('Session invalid.', e.getMessage());
      }
    }
  }

  @isTest
  static void testRegisterFailedSessionAttempt_LocksAfterThreshold() {
    Portal_Users__c employee = [
      SELECT
        Id,
        Session_Token__c,
        Session_Expires_At__c,
        Session_Failed_Attempts__c,
        Session_Locked_Until__c
      FROM Portal_Users__c
      LIMIT 1
    ];

    for (Integer i = 0; i < PWChrono_Constants.PORTAL_SESSION_MAX_FAILED_ATTEMPTS; i++) {
      PWChrono_GuestSession.registerFailedSessionAttempt(employee);
      employee = [
        SELECT
          Id,
          Session_Token__c,
          Session_Expires_At__c,
          Session_Failed_Attempts__c,
          Session_Locked_Until__c
        FROM Portal_Users__c
        WHERE Id = :employee.Id
        LIMIT 1
      ];
    }

    System.assertEquals(
      null,
      employee.Session_Token__c,
      'Session token should be cleared after lockout threshold.'
    );
    System.assertEquals(
      null,
      employee.Session_Expires_At__c,
      'Session expiry should be cleared after lockout threshold.'
    );
    System.assert(
      employee.Session_Locked_Until__c != null,
      'Lockout timestamp should be set after repeated failed attempts.'
    );
    System.assertEquals(
      0,
      Integer.valueOf(employee.Session_Failed_Attempts__c),
      'Failed attempts counter should reset when lockout is applied.'
    );
  }

  @isTest
  static void testClearSessionValidationState_ResetsFields() {
    Portal_Users__c employee = [SELECT Id FROM Portal_Users__c LIMIT 1];

    employee.Session_Failed_Attempts__c = 3;
    employee.Session_Locked_Until__c = System.now().addMinutes(10);
    update employee;

    employee = [
      SELECT Id, Session_Failed_Attempts__c, Session_Locked_Until__c
      FROM Portal_Users__c
      WHERE Id = :employee.Id
      LIMIT 1
    ];

    PWChrono_GuestSession.clearSessionValidationState(employee);

    Portal_Users__c updatedEmployee = [
      SELECT Id, Session_Failed_Attempts__c, Session_Locked_Until__c
      FROM Portal_Users__c
      WHERE Id = :employee.Id
      LIMIT 1
    ];

    System.assertEquals(
      0,
      Integer.valueOf(updatedEmployee.Session_Failed_Attempts__c),
      'Failed attempts should be reset.'
    );
    System.assertEquals(
      null,
      updatedEmployee.Session_Locked_Until__c,
      'Lockout timestamp should be cleared.'
    );
  }
}
