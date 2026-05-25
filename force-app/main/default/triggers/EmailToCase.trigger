trigger EmailToCase on Case(after insert) {
  try {
    switch on Trigger.operationType {
      when AFTER_INSERT {
        EmailToCaseTriggerHandler.AfterInsert(Trigger.New);
      }
    }
  } catch (Exception e) {
    system.debug('Trigger Error: ' + e.getMessage());
  }
}
