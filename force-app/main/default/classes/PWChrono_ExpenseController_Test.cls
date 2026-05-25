/**
 * @description Tests for PWChrono_ExpenseController.
 *              Covers all new framework methods and legacy delegation.
 */
@IsTest
private class PWChrono_ExpenseController_Test {
  @TestSetup
  static void setup() {
    PWChrono_ExpenseTestDataFactory.setupStandardTestData();
  }

  // ─────────────────────── getMyExpenseClaimList ────────────────────────────

  @IsTest
  static void testGetMyExpenseClaimList_noFilter_returnsClaims() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Expense_Claim__c> result = PWChrono_ExpenseController.getMyExpenseClaimList(
      null,
      null,
      null,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assert(result.size() >= 4, 'Should return at least 4 test claims');
  }

  @IsTest
  static void testGetMyExpenseClaimList_statusFilter_returnsFiltered() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Expense_Claim__c> result = PWChrono_ExpenseController.getMyExpenseClaimList(
      'Approved',
      null,
      null,
      emp.Id,
      null
    );
    Test.stopTest();

    for (PWChrono_Expense_Claim__c c : result) {
      System.assertEquals(
        'Approved',
        c.Status__c,
        'Should only return Approved claims'
      );
    }
  }

  // ─────────────────────── getExpenseClaimDetail ───────────────────────────

  @IsTest
  static void testGetExpenseClaimDetail_owner_returnsFullRecord() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_Expense_Claim__c result = PWChrono_ExpenseController.getExpenseClaimDetail(
      claim.Id,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertEquals(claim.Id, result.Id, 'Should return matching claim');
  }

  @IsTest
  static void testGetExpenseClaimDetail_approver_returnsFullRecord() {
    Portal_Users__c mgr = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Manager'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_Expense_Claim__c result = PWChrono_ExpenseController.getExpenseClaimDetail(
      claim.Id,
      mgr.Id,
      null
    );
    Test.stopTest();

    System.assertEquals(
      claim.Id,
      result.Id,
      'Approver should also be able to read'
    );
  }

  @IsTest
  static void testGetExpenseClaimDetail_notFoundId_throwsException() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    try {
      PWChrono_ExpenseController.getExpenseClaimDetail(
        '001000000000000AAA',
        emp.Id,
        null
      );
      System.assert(false, 'Should throw for non-existent claim');
    } catch (AuraHandledException e) {
      System.assert(e.getMessage().length() > 0);
    }
    Test.stopTest();
  }

  // ─────────────────────── saveExpenseClaim ────────────────────────────────

  @IsTest
  static void testSaveExpenseClaim_newClaim_returnsDraft() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_ExpenseValidator.ExpenseClaimDTO dto = PWChrono_ExpenseTestDataFactory.buildClaimDTO(
      null,
      Date.today().addDays(-2)
    );

    Test.startTest();
    PWChrono_Expense_Claim__c result = PWChrono_ExpenseController.saveExpenseClaim(
      dto,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result.Id);
    System.assertEquals('Draft', result.Status__c);
  }

  // ─────────────────────── submitExpenseClaim ──────────────────────────────

  @IsTest
  static void testSubmitExpenseClaim_draft_transitionsToSubmitted() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c draft = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      WHERE Status__c = 'Draft' AND Employees__c = :emp.Id
      LIMIT 1
    ];
    PWChrono_ExpenseTestDataFactory.createItem(
      draft.Id,
      Date.today().addDays(-3),
      'Travel',
      100.00
    );

    Test.startTest();
    PWChrono_Expense_Claim__c result = PWChrono_ExpenseController.submitExpenseClaim(
      draft.Id,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertEquals('Submitted', result.Status__c);
  }

  // ─────────────────────── cancelExpenseClaim ──────────────────────────────

  @IsTest
  static void testCancelExpenseClaim_draft_setsCancelled() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c draft = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      WHERE Status__c = 'Draft' AND Employees__c = :emp.Id
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_Expense_Claim__c result = PWChrono_ExpenseController.cancelExpenseClaim(
      draft.Id,
      'Not needed.',
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertEquals('Cancelled', result.Status__c);
  }

  // ─────────────────────── processExpenseClaimApproval ─────────────────────

  @IsTest
  static void testProcessExpenseClaimApproval_approve_succeeds() {
    Portal_Users__c mgr = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Manager'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c submitted = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      WHERE Status__c = 'Submitted'
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_Expense_Claim__c result = PWChrono_ExpenseController.processExpenseClaimApproval(
      submitted.Id,
      'Approve',
      'All good.',
      mgr.Id,
      null
    );
    Test.stopTest();

    System.assertEquals('Approved', result.Status__c);
  }

  @IsTest
  static void testProcessExpenseClaimApproval_reject_succeeds() {
    Portal_Users__c mgr = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Manager'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c submitted = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      WHERE Status__c = 'Submitted'
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_Expense_Claim__c result = PWChrono_ExpenseController.processExpenseClaimApproval(
      submitted.Id,
      'Reject',
      'Receipts missing.',
      mgr.Id,
      null
    );
    Test.stopTest();

    System.assertEquals('Rejected', result.Status__c);
    System.assertNotEquals(null, result.Rejection_Reason__c);
  }

  // ─────────────────────── getTeamExpenseClaimsForApproval ─────────────────

  @IsTest
  static void testGetTeamExpenseClaimsForApproval_returnsPendingQueue() {
    Portal_Users__c mgr = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Manager'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Expense_Claim__c> result = PWChrono_ExpenseController.getTeamExpenseClaimsForApproval(
      mgr.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result);
    for (PWChrono_Expense_Claim__c c : result) {
      System.assertEquals(
        'Submitted',
        c.Status__c,
        'Should only contain Submitted claims'
      );
    }
  }

  // ─────────────────────── getTeamExpenseClaims ────────────────────────────

  @IsTest
  static void testGetTeamExpenseClaims_noFilter_returnsAll() {
    Portal_Users__c mgr = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Manager'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Expense_Claim__c> result = PWChrono_ExpenseController.getTeamExpenseClaims(
      null,
      mgr.Id,
      null
    );
    Test.stopTest();

    System.assert(result.size() >= 4, 'Should return all team claims');
  }

  // ─────────────────────── getExpenseDashboardSummary ──────────────────────

  @IsTest
  static void testGetExpenseDashboardSummary_returnsSummary() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_ExpenseService.ExpenseDashboardDTO result = PWChrono_ExpenseController.getExpenseDashboardSummary(
      null,
      null,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should return dashboard DTO');
    System.assert(result.totalClaims >= 4, 'Should count all test claims');
  }

  // ─────────────────────── getExpenseComments ──────────────────────────────

  @IsTest
  static void testGetExpenseComments_returnsListOrEmpty() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_RequestCommentService.RequestCommentDTO> result = PWChrono_ExpenseController.getExpenseComments(
      claim.Id,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should not return null');
  }

  // ─────────────────────── getExpenseFiles ─────────────────────────────────

  @IsTest
  static void testGetExpenseFiles_returnsListOrEmpty() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_RequestAttachmentService.FileDescriptorDTO> result = PWChrono_ExpenseController.getExpenseFiles(
      claim.Id,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Should not return null');
  }

  // ─────────────────────── addExpenseComment ───────────────────────────────

  @IsTest
  static void testAddExpenseComment_owner_addsComment() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      LIMIT 1
    ];

    Test.startTest();
    PWChrono_ExpenseController.addExpenseComment(
      claim.Id,
      'Test comment text.',
      emp.Id,
      null
    );
    Test.stopTest();
    // No exception = pass
    System.assert(true, 'Comment should be added without exception');
  }

  // ─────────────────────── Legacy method delegation ────────────────────────

  @IsTest
  static void testLegacyGetMyClaims_returnsAllEmployeeClaims() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Expense_Claim__c> result = PWChrono_ExpenseController.getMyClaims(
      emp.Id,
      null
    );
    Test.stopTest();

    System.assert(
      result.size() >= 4,
      'Legacy getMyClaims should return all claims'
    );
  }

  @IsTest
  static void testLegacyGetClaimItems_returnsItems() {
    Portal_Users__c emp = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Role__c = 'Employee'
      LIMIT 1
    ];
    PWChrono_Expense_Claim__c claim = [
      SELECT Id
      FROM PWChrono_Expense_Claim__c
      WHERE Status__c = 'Submitted' AND Employees__c = :emp.Id
      LIMIT 1
    ];

    Test.startTest();
    List<PWChrono_Expense_Item__c> result = PWChrono_ExpenseController.getClaimItems(
      claim.Id,
      emp.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Legacy getClaimItems should work');
  }
}
