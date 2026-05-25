trigger TLG_TeamStatusTrigger on TLG_Team_Status__c(
  before insert,
  before update
) {
  TLG_TeamStatusTriggerHandler.handleTrigger(
    Trigger.new,
    Trigger.oldMap,
    Trigger.isInsert,
    Trigger.isUpdate,
    Trigger.isBefore,
    Trigger.isAfter
  );
}
