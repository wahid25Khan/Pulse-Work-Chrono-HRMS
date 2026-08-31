/**
 * @description Retired compatibility trigger for legacy leave records.
 * Runtime automation moved to PWChrono_CanonicalLeaveTrigger on Leave__c.
 */
trigger PWChrono_LeaveTrigger on PWChrono_Leave__c(before insert) {
  // Intentionally inactive after the canonical Leave__c cutover.
}
