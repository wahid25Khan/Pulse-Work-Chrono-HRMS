/**
 * @description Trigger on canonical Leave__c records to validate balances and update allocations.
 */
trigger PWChrono_CanonicalLeaveTrigger on Leave__c(
  before insert,
  before update,
  after insert,
  after update,
  after delete,
  after undelete
) {
  if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
    PWChrono_LeaveTriggerHandler.validateLeaveBalance(
      Trigger.new,
      Trigger.oldMap
    );
  }

  if (Trigger.isAfter) {
    if (Trigger.isInsert || Trigger.isUndelete) {
      PWChrono_LeaveTriggerHandler.updateLeaveAllocation(Trigger.new, null);
    } else if (Trigger.isUpdate) {
      PWChrono_LeaveTriggerHandler.updateLeaveAllocation(
        Trigger.new,
        Trigger.oldMap
      );
    } else if (Trigger.isDelete) {
      PWChrono_LeaveTriggerHandler.updateLeaveAllocation(Trigger.old, null);
    }
  }
}
