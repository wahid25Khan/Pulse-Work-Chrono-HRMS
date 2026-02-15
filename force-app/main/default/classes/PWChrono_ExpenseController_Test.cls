@isTest
private class PWChrono_ExpenseController_Test {
  @TestSetup
  static void makeData() {
    // Create User and Employee
    User testUser = PWChrono_TestDataFactory.createTestUser('Standard User');
    PWChrono_TestDataFactory.assignPermissionSet(
      testUser.Id,
      'PWChrono_Employee'
    );
    Portal_Users__c employee = PWChrono_TestDataFactory.createTestEmployee(
      testUser.Id
    );

    // Create Expense Claim
    PWChrono_Expense_Claim__c claim = new PWChrono_Expense_Claim__c(
      Employees__c = employee.Id,
      Claim_Date__c = Date.today(),
      Description__c = 'Travel Expenses',
      Status__c = PWChrono_Constants.STATUS_DRAFT,
      OwnerId = testUser.Id
    );
    insert claim;

    // Create Expense Item
    PWChrono_Expense_Item__c item = new PWChrono_Expense_Item__c(
      Expense_Claim__c = claim.Id,
      Date__c = Date.today(),
      Type__c = 'Travel',
      Amount__c = 100,
      Description__c = 'Flight Ticket'
    );
    insert item;
  }

  @isTest
  static void testGetMyClaims() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'Standard User'
      LIMIT 1
    ];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Expense_Claim__c> claims = PWChrono_ExpenseController.getMyClaims(
        null,
        null
      );
      Test.stopTest();

      System.assertEquals(1, claims.size(), 'Should return 1 claim');
    }
  }

  @isTest
  static void testGetClaimItems() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'Standard User'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      LIMIT 1
    ];

    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Expense_Item__c> items = PWChrono_ExpenseController.getClaimItems(
        claim.Id,
        null,
        null
      );
      Test.stopTest();

      System.assertEquals(1, items.size(), 'Should return 1 item');
    }
  }

  @isTest
  static void testSaveClaim() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'Standard User'
      LIMIT 1
    ];

    System.runAs(testUser) {
      PWChrono_Expense_Claim__c newClaim = new PWChrono_Expense_Claim__c(
        Claim_Date__c = Date.today(),
        Description__c = 'Office Supplies',
        Status__c = PWChrono_Constants.STATUS_DRAFT
      );

      List<PWChrono_Expense_Item__c> items = new List<PWChrono_Expense_Item__c>{
        new PWChrono_Expense_Item__c(
          Date__c = Date.today(),
          Type__c = 'Other',
          Amount__c = 50,
          Description__c = 'Pens'
        )
      };

      Test.startTest();
      Portal_Users__c currentEmployee = [
        SELECT Id
        FROM Portal_Users__c
        WHERE User__c = :testUser.Id
        LIMIT 1
      ];
      PWChrono_Expense_Claim__c savedClaim = PWChrono_ExpenseController.saveClaim(
        newClaim,
        items,
        currentEmployee.Id,
        null
      );
      Test.stopTest();

      System.assertNotEquals(null, savedClaim.Id, 'Claim should be saved');

      List<PWChrono_Expense_Item__c> savedItems = [
        SELECT Id
        FROM PWChrono_Expense_Item__c
        WHERE Expense_Claim__c = :savedClaim.Id
      ];
      System.assertEquals(1, savedItems.size(), 'Item should be saved');
    }
  }

  @isTest
  static void testSubmitClaim() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'Standard User'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      LIMIT 1
    ];

    System.runAs(testUser) {
      Test.startTest();
      Portal_Users__c currentEmployee = [
        SELECT Id
        FROM Portal_Users__c
        WHERE User__c = :testUser.Id
        LIMIT 1
      ];
      PWChrono_ExpenseController.submitClaim(claim.Id, currentEmployee.Id, null);
      Test.stopTest();

      PWChrono_Expense_Claim__c updatedClaim = [
        SELECT Status__c
        FROM PWChrono_Expense_Claim__c
        WHERE Id = :claim.Id
      ];
      System.assertEquals(
        PWChrono_Constants.STATUS_SUBMITTED,
        updatedClaim.Status__c,
        'Status should be Submitted'
      );
    }
  }

  @isTest
  static void testDeleteClaim() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE LastName = 'Standard User'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      LIMIT 1
    ];

    System.runAs(testUser) {
      Test.startTest();
      Portal_Users__c currentEmployee = [
        SELECT Id
        FROM Portal_Users__c
        WHERE User__c = :testUser.Id
        LIMIT 1
      ];
      PWChrono_ExpenseController.deleteClaim(claim.Id, currentEmployee.Id, null);
      Test.stopTest();

      List<PWChrono_Expense_Claim__c> claims = [
        SELECT Id
        FROM PWChrono_Expense_Claim__c
        WHERE Id = :claim.Id
      ];
      System.assert(claims.isEmpty(), 'Claim should be deleted');
    }
  }
}