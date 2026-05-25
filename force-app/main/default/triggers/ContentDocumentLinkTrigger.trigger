trigger ContentDocumentLinkTrigger on ContentDocumentLink(before insert) {
  try {
    List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();

    for (ContentDocumentLink cdl : Trigger.new) {
      if (
        cdl.LinkedEntityId != null &&
        String.valueOf(cdl.LinkedEntityId).startsWith('006')
      ) {
        // Check if the LinkedEntity is an Opportunity (Assuming 006 is the key prefix for Opportunity)
        Opportunity opp = [
          SELECT Id, AccountId, CreatedDate
          FROM Opportunity
          WHERE Id = :cdl.LinkedEntityId
          LIMIT 1
        ];

        if (opp != null) {
          // Create a new ContentDocumentLink for the Opportunity's account
          ContentDocumentLink newLink = new ContentDocumentLink();
          newLink.ContentDocumentId = cdl.ContentDocumentId;
          newLink.LinkedEntityId = opp.AccountId;
          newLink.ShareType = 'V'; // 'V' for view access, you can adjust as needed
          newLink.Visibility = 'AllUsers'; // You can adjust visibility as needed

          newLinks.add(newLink);
        }
      }
    }

    // Insert the new ContentDocumentLinks for the Opportunity's account
    if (!newLinks.isEmpty()) {
      insert newLinks;
    }
  } catch (exception e) {
  }

}
