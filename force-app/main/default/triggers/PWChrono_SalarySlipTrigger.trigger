/**
 * @description Trigger on PWChrono_Salary_Slip__c to track salary history
 */
trigger PWChrono_SalarySlipTrigger on PWChrono_Salary_Slip__c(after insert) {
  if (Trigger.isAfter && Trigger.isInsert) {
    PWChrono_SalarySlipTriggerHandler.createSalaryHistory(Trigger.new);
  }
}
