trigger CaseGoogleDriveTrigger on Case (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseGoogleDriveHandler.afterInsert(Trigger.new);
    }
}