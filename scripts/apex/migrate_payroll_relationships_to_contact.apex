// Backfills canonical Contact relationships after Portal_Users__c.Contact__c
// has been reviewed and completed. Default is a no-DML dry run.
Boolean applyChanges = false;

List<PWChrono_Salary_Slip__c> slipUpdates = new List<PWChrono_Salary_Slip__c>();
List<PWChrono_Salary_Assignment__c> assignmentUpdates = new List<PWChrono_Salary_Assignment__c>();
List<PWChrono_Salary_History__c> historyUpdates = new List<PWChrono_Salary_History__c>();
List<String> unresolved = new List<String>();

for (PWChrono_Salary_Slip__c slip : [
  SELECT Id, Contact__c, Employees__c, Employees__r.Contact__c
  FROM PWChrono_Salary_Slip__c
  WHERE Contact__c = NULL
]) {
  if (slip.Employees__c == null || slip.Employees__r.Contact__c == null) {
    unresolved.add('SalarySlip:' + slip.Id);
    continue;
  }
  slipUpdates.add(
    new PWChrono_Salary_Slip__c(
      Id = slip.Id,
      Contact__c = slip.Employees__r.Contact__c
    )
  );
}

for (PWChrono_Salary_Assignment__c assignment : [
  SELECT Id, Contact__c, Employees__c, Employees__r.Contact__c
  FROM PWChrono_Salary_Assignment__c
  WHERE Contact__c = NULL
]) {
  if (
    assignment.Employees__c == null ||
    assignment.Employees__r.Contact__c == null
  ) {
    unresolved.add('SalaryAssignment:' + assignment.Id);
    continue;
  }
  assignmentUpdates.add(
    new PWChrono_Salary_Assignment__c(
      Id = assignment.Id,
      Contact__c = assignment.Employees__r.Contact__c
    )
  );
}

for (PWChrono_Salary_History__c history : [
  SELECT Id, Contact__c, Employee__c, Employee__r.Contact__c
  FROM PWChrono_Salary_History__c
  WHERE Contact__c = NULL
]) {
  if (history.Employee__c == null || history.Employee__r.Contact__c == null) {
    unresolved.add('SalaryHistory:' + history.Id);
    continue;
  }
  historyUpdates.add(
    new PWChrono_Salary_History__c(
      Id = history.Id,
      Contact__c = history.Employee__r.Contact__c
    )
  );
}

System.debug(
  LoggingLevel.WARN,
  'PWCHRONO_PAYROLL_CONTACT_MIGRATION applyChanges=' + applyChanges
);
System.debug(LoggingLevel.WARN, 'salarySlipUpdates=' + slipUpdates.size());
System.debug(
  LoggingLevel.WARN,
  'salaryAssignmentUpdates=' + assignmentUpdates.size()
);
System.debug(
  LoggingLevel.WARN,
  'salaryHistoryUpdates=' + historyUpdates.size()
);
System.debug(
  LoggingLevel.WARN,
  'unresolved=' + JSON.serializePretty(unresolved)
);

if (applyChanges) {
  if (!slipUpdates.isEmpty()) {
    update slipUpdates;
  }
  if (!assignmentUpdates.isEmpty()) {
    update assignmentUpdates;
  }
  if (!historyUpdates.isEmpty()) {
    update historyUpdates;
  }
  System.debug(LoggingLevel.WARN, 'PAYROLL_CONTACT_MIGRATION_APPLIED');
} else {
  System.debug(LoggingLevel.WARN, 'DRY_RUN_ONLY_NO_DML');
}
