@IsTest
private class PWChrono_LeaveController_Test {
  @TestSetup
  static void setupTestData() {
    PWChrono_LeaveTestDataFactory.setupStandardTestData();
  }

  private static PWChrono_LeaveTestDataFactory.TestDataBundle getBundle() {
    PWChrono_LeaveTestDataFactory.TestDataBundle bundle = new PWChrono_LeaveTestDataFactory.TestDataBundle();
    bundle.employee = [
      SELECT Id, Reports_To__c
      FROM Portal_Users__c
      WHERE Name = 'Test Employee'
      LIMIT 1
    ];
    bundle.manager = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Name = 'Test Manager'
      LIMIT 1
    ];
    bundle.annualLeave = [
      SELECT Id
      FROM PWChrono_Leave_Type__c
      WHERE Name = 'Annual Leave'
      LIMIT 1
    ];
    return bundle;
  }

  @IsTest
  static void testSubmitApproveAndLedgerHistory() {
    PWChrono_LeaveTestDataFactory.TestDataBundle bundle = getBundle();

    PWChrono_LeaveValidator.LeaveDTO dto = new PWChrono_LeaveValidator.LeaveDTO();
    dto.leaveTypeId = bundle.annualLeave.Id;
    dto.fromDate = Date.today().addDays(5);
    dto.toDate = Date.today().addDays(7);
    dto.reason = 'Controller test';
    dto.halfDay = false;

    Test.startTest();
    PWChrono_Leave__c createdLeave = PWChrono_LeaveController.submitLeaveApplication(
      dto,
      String.valueOf(bundle.employee.Id),
      null
    );
    PWChrono_Leave__c approvedLeave = PWChrono_LeaveController.processLeaveApproval(
      createdLeave.Id,
      'Approve',
      'Looks good',
      String.valueOf(bundle.manager.Id),
      null
    );
    List<PWChrono_LeaveLedgerService.LedgerEntryDTO> ledgerEntries = PWChrono_LeaveController.getLeaveLedgerHistory(
      createdLeave.Id,
      String.valueOf(bundle.employee.Id),
      null
    );
    Test.stopTest();

    System.assertEquals('Approved', approvedLeave.Status__c);
    System.assertEquals(
      1,
      ledgerEntries.size(),
      'Approval should create a ledger entry.'
    );
    System.assertEquals('Used', ledgerEntries[0].transactionType);
  }

  @IsTest
  static void testAddCommentAndRetrieveComments() {
    PWChrono_LeaveTestDataFactory.TestDataBundle bundle = getBundle();
    PWChrono_Leave__c leaveRecord = PWChrono_LeaveTestDataFactory.createLeave(
      bundle.employee.Id,
      bundle.annualLeave.Id,
      bundle.manager.Id,
      Date.today().addDays(2),
      Date.today().addDays(2),
      'Submitted'
    );

    Test.startTest();
    PWChrono_RequestCommentService.RequestCommentDTO newComment = PWChrono_LeaveController.addLeaveComment(
      leaveRecord.Id,
      'Please approve quickly.',
      String.valueOf(bundle.employee.Id),
      null
    );
    List<PWChrono_RequestCommentService.RequestCommentDTO> comments = PWChrono_LeaveController.getLeaveComments(
      leaveRecord.Id,
      String.valueOf(bundle.employee.Id),
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, newComment.commentId);
    System.assertEquals(1, comments.size());
    System.assertEquals('Please approve quickly.', comments[0].text);
  }

  @IsTest
  static void testUploadLeaveFileAndRetrieveFiles() {
    PWChrono_LeaveTestDataFactory.TestDataBundle bundle = getBundle();
    PWChrono_Leave__c leaveRecord = PWChrono_LeaveTestDataFactory.createLeave(
      bundle.employee.Id,
      bundle.annualLeave.Id,
      bundle.manager.Id,
      Date.today().addDays(3),
      Date.today().addDays(3),
      'Submitted'
    );

    Test.startTest();
    PWChrono_RequestAttachmentService.FileDescriptorDTO uploadedFile = PWChrono_LeaveController.uploadLeaveFile(
      leaveRecord.Id,
      'medical-note.txt',
      EncodingUtil.base64Encode(Blob.valueOf('hello')),
      String.valueOf(bundle.employee.Id),
      null
    );
    List<PWChrono_RequestAttachmentService.FileDescriptorDTO> files = PWChrono_LeaveController.getLeaveFiles(
      leaveRecord.Id,
      String.valueOf(bundle.employee.Id),
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, uploadedFile.contentDocumentId);
    System.assertEquals(1, files.size());
    System.assertEquals('medical-note.txt', files[0].name);

    PWChrono_Leave__c refreshedLeave = [
      SELECT Certificate_Uploaded__c
      FROM PWChrono_Leave__c
      WHERE Id = :leaveRecord.Id
      LIMIT 1
    ];
    System.assertEquals(true, refreshedLeave.Certificate_Uploaded__c);
  }
}
