trigger LinkNotesToOpportunity on Note(after insert) {
  public static void linkNotesToOpportunity(List<Note> newNotes) {
    System.debug('Trigger is running on Note creation.');

    Set<Id> opportunityIds = new Set<Id>();
    Map<Id, Opportunity> opportunitiesById = new Map<Id, Opportunity>();

    // Collect Opportunity IDs from the Parent IDs
    for (Note note : newNotes) {
      if (
        note.ParentId != null && String.valueOf(note.ParentId).startsWith('006')
      ) {
        opportunityIds.add(note.ParentId);
      }
    }

    System.debug('Opportunity IDs: ' + opportunityIds);

    // Query for Opportunities and store them in a map
    List<Opportunity> relatedOpportunities = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE Id IN :opportunityIds
    ];
    for (Opportunity opp : relatedOpportunities) {
      opportunitiesById.put(opp.Id, opp);
    }

    // Process each Note and perform actions based on AccountId
    for (Note note : newNotes) {
      if (opportunitiesById.containsKey(note.ParentId)) {
        Opportunity relatedOpportunity = opportunitiesById.get(note.ParentId);
        Id accountId = relatedOpportunity.AccountId;

        // Perform actions based on accountId, e.g., log, trigger other processes
        System.debug(
          'Note with ParentId ' +
            note.ParentId +
            ' is related to AccountId ' +
            accountId
        );
        // You can add more logic or invoke other methods based on accountId
      }
    }
  }

  // Trigger handler
  public void onAfterInsert(List<Note> newNotes) {
    linkNotesToOpportunity(newNotes);
  }
}
