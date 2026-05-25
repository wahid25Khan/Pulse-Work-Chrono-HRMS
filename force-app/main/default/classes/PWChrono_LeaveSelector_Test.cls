@IsTest
private class PWChrono_LeaveSelector_Test {
  @TestSetup
  static void setupTestData() {
    PWChrono_LeaveTestDataFactory.setupStandardTestData();
  }

  @IsTest
  static void testGetActiveLeaveTypes_IncludeInactive() {
    PWChrono_Leave_Type__c inactiveType = PWChrono_LeaveTestDataFactory.createLeaveType(
      'Comp Off',
      5
    );
    inactiveType.Is_Active__c = false;
    update inactiveType;

    Test.startTest();
    List<PWChrono_Leave_Type__c> activeOnly = PWChrono_LeaveSelector.getActiveLeaveTypes(
      false
    );
    List<PWChrono_Leave_Type__c> includeInactive = PWChrono_LeaveSelector.getActiveLeaveTypes(
      true
    );
    Test.stopTest();

    System.assertEquals(
      false,
      new Map<Id, PWChrono_Leave_Type__c>(activeOnly)
        .containsKey(inactiveType.Id)
    );
    System.assertEquals(
      true,
      new Map<Id, PWChrono_Leave_Type__c>(includeInactive)
        .containsKey(inactiveType.Id)
    );
  }

  @IsTest
  static void testBlockedDateAndPaidSalaryDetection() {
    Portal_Users__c employee = [
      SELECT Id
      FROM Portal_Users__c
      WHERE Name = 'Test Employee'
      LIMIT 1
    ];
    Date targetDate = Date.today().addDays(10);
    PWChrono_LeaveTestDataFactory.createBlockedDate(targetDate);
    PWChrono_LeaveTestDataFactory.createPaidSalarySlip(employee.Id, targetDate);

    Test.startTest();
    Set<Date> blockedDates = PWChrono_LeaveSelector.getBlockedDateSet(
      targetDate,
      targetDate,
      null
    );
    Boolean salaryProcessed = PWChrono_LeaveSelector.hasPaidSalarySlipInRange(
      employee.Id,
      targetDate,
      targetDate
    );
    Test.stopTest();

    System.assertEquals(true, blockedDates.contains(targetDate));
    System.assertEquals(true, salaryProcessed);
  }
}
