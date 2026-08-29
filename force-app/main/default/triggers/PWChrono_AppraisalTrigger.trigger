trigger PWChrono_AppraisalTrigger on PWChrono_Appraisal__c(after update) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    PWChrono_AppraisalTriggerHandler.handleAfterUpdate(
      Trigger.new,
      Trigger.oldMap
    );
  }
}