trigger KB_TaskTrigger on TLG_Task__c(
  after insert,
  after update,
  after delete,
  after undelete
) {
  KB_TaskTriggerHandler.handleTargetCompletionUpdate(
    Trigger.new,
    Trigger.old,
    Trigger.operationType
  );
}
