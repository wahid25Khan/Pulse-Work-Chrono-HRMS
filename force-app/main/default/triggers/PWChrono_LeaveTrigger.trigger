/**
 * @description Trigger on PWChrono_Leave__c to update leave allocations
 */
trigger PWChrono_LeaveTrigger on PWChrono_Leave__c(
  before insert,
  before update,
  after insert,
  after update,
  after delete,
  after undelete
) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      PWChrono_LeaveTriggerHandler.validateLeaveBalance(
        Trigger.new,
        Trigger.oldMap
      );
    }
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
