@isTest
private class PWChrono_JobRequisitionController_Test {
  @testSetup
  static void setup() {
    PWChrono_TestDataFactory.createTestUsers();
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

    System.runAs(testUser) {
      PWChrono_TestDataFactory.createTestEmployee(testUser.Id);

      PWChrono_Department__c dept = new PWChrono_Department__c(
        Name = 'Product',
        Is_Active__c = true
      );
      insert dept;

      PWChrono_Designation__c desig = new PWChrono_Designation__c(
        Name = 'Product Manager',
        Is_Active__c = true
      );
      insert desig;

      PWChrono_Staffing_Plan__c plan = new PWChrono_Staffing_Plan__c(
        Name = 'Q4 Hiring Plan',
        Company__c = 'PWChrono',
        Department__c = dept.Id,
        From_Date__c = Date.today(),
        To_Date__c = Date.today().addMonths(3),
        Status__c = 'Draft'
      );
      insert plan;

      PWChrono_Job_Requisition__c req = new PWChrono_Job_Requisition__c(
        Name = 'Product Manager - Q4',
        Department__c = dept.Id,
        Designation__c = desig.Id,
        No_of_Positions__c = 2,
        Expected_Compensation__c = 80000,
        Company__c = 'PWChrono',
        Status__c = 'Pending',
        Expected_By_Date__c = Date.today().addMonths(2),
        Staffing_Plan__c = plan.Id,
        Reason_for_Hiring__c = 'New Position'
      );
      insert req;
    }
  }

  @isTest
  static void testGetJobRequisitions_All() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Job_Requisition__c> reqs = PWChrono_JobRequisitionController.getJobRequisitions(
        null,
        null,
        null
      );
      Test.stopTest();
      System.assertEquals(1, reqs.size(), 'Should return 1 requisition');
    }
  }

  @isTest
  static void testGetJobRequisitions_FilterByStatus() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Job_Requisition__c> pending = PWChrono_JobRequisitionController.getJobRequisitions(
        'Pending',
        null,
        null
      );
      List<PWChrono_Job_Requisition__c> filled = PWChrono_JobRequisitionController.getJobRequisitions(
        'Filled',
        null,
        null
      );
      Test.stopTest();
      System.assertEquals(1, pending.size(), 'Should return 1 Pending');
      System.assertEquals(0, filled.size(), 'Should return 0 Filled');
    }
  }

  @isTest
  static void testGetJobRequisitionById() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      PWChrono_Job_Requisition__c existing = [
        SELECT Id
        FROM PWChrono_Job_Requisition__c
        LIMIT 1
      ];
      Test.startTest();
      PWChrono_Job_Requisition__c rec = PWChrono_JobRequisitionController.getJobRequisitionById(
        existing.Id,
        null,
        null
      );
      Test.stopTest();
      System.assertEquals(
        existing.Id,
        rec.Id,
        'Should return the correct record'
      );
    }
  }

  @isTest
  static void testGetJobRequisitionById_NotFound() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      PWChrono_Job_Requisition__c dummy = new PWChrono_Job_Requisition__c();
      dummy.Id = '0Bk000000000001AAA'; // fake Id pattern
      Test.startTest();
      try {
        PWChrono_JobRequisitionController.getJobRequisitionById(
          dummy.Id,
          null,
          null
        );
        System.assert(false, 'Expected AuraHandledException');
      } catch (AuraHandledException e) {
        System.assert(
          e.getMessage().contains('not found'),
          'Should say not found'
        );
      }
      Test.stopTest();
    }
  }

  @isTest
  static void testSaveJobRequisition_Insert() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      PWChrono_Department__c dept = [
        SELECT Id
        FROM PWChrono_Department__c
        LIMIT 1
      ];
      PWChrono_Job_Requisition__c newReq = new PWChrono_Job_Requisition__c(
        Name = 'New Analyst Role',
        Department__c = dept.Id,
        No_of_Positions__c = 1,
        Status__c = 'Pending'
      );
      Test.startTest();
      Id savedId = PWChrono_JobRequisitionController.saveJobRequisition(
        JSON.serialize(newReq),
        null,
        null
      );
      Test.stopTest();
      System.assertNotEquals(null, savedId, 'Should return a new Id');
      List<PWChrono_Job_Requisition__c> all = [
        SELECT Id
        FROM PWChrono_Job_Requisition__c
      ];
      System.assertEquals(2, all.size(), 'Should now have 2 records');
    }
  }

  @isTest
  static void testSaveJobRequisition_Update() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      PWChrono_Job_Requisition__c existing = [
        SELECT Id, Name, No_of_Positions__c, Status__c
        FROM PWChrono_Job_Requisition__c
        LIMIT 1
      ];
      existing.No_of_Positions__c = 5;
      Test.startTest();
      Id savedId = PWChrono_JobRequisitionController.saveJobRequisition(
        JSON.serialize(existing),
        null,
        null
      );
      Test.stopTest();
      PWChrono_Job_Requisition__c updated = [
        SELECT No_of_Positions__c
        FROM PWChrono_Job_Requisition__c
        WHERE Id = :savedId
      ];
      System.assertEquals(
        5,
        updated.No_of_Positions__c,
        'Positions should be updated to 5'
      );
    }
  }

  @isTest
  static void testUpdateJobRequisitionStatus() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      PWChrono_Job_Requisition__c existing = [
        SELECT Id
        FROM PWChrono_Job_Requisition__c
        LIMIT 1
      ];
      Test.startTest();
      PWChrono_JobRequisitionController.updateJobRequisitionStatus(
        existing.Id,
        'Open & Approved',
        null,
        null
      );
      Test.stopTest();
      PWChrono_Job_Requisition__c updated = [
        SELECT Status__c
        FROM PWChrono_Job_Requisition__c
        WHERE Id = :existing.Id
      ];
      System.assertEquals(
        'Open & Approved',
        updated.Status__c,
        'Status should be Open & Approved'
      );
    }
  }

  @isTest
  static void testDeleteJobRequisition() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      PWChrono_Job_Requisition__c existing = [
        SELECT Id
        FROM PWChrono_Job_Requisition__c
        LIMIT 1
      ];
      Test.startTest();
      PWChrono_JobRequisitionController.deleteJobRequisition(
        existing.Id,
        null,
        null
      );
      Test.stopTest();
      List<PWChrono_Job_Requisition__c> remaining = [
        SELECT Id
        FROM PWChrono_Job_Requisition__c
      ];
      System.assertEquals(
        0,
        remaining.size(),
        'Should have 0 records after delete'
      );
    }
  }

  @isTest
  static void testGetActiveDesignations() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Designation__c> desigs = PWChrono_JobRequisitionController.getActiveDesignations();
      Test.stopTest();
      System.assert(!desigs.isEmpty(), 'Should return at least 1 designation');
    }
  }

  @isTest
  static void testGetActiveDepartments() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Department__c> depts = PWChrono_JobRequisitionController.getActiveDepartments();
      Test.stopTest();
      System.assert(!depts.isEmpty(), 'Should return at least 1 department');
    }
  }

  @isTest
  static void testGetAvailableStaffingPlans() {
    User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
    System.runAs(testUser) {
      Test.startTest();
      List<PWChrono_Staffing_Plan__c> plans = PWChrono_JobRequisitionController.getAvailableStaffingPlans();
      Test.stopTest();
      System.assert(!plans.isEmpty(), 'Should return at least 1 staffing plan');
    }
  }
}
