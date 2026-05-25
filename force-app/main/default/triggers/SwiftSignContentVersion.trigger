trigger SwiftSignContentVersion on ContentVersion(after insert) {
  List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
  List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
  List<SwiftSign_File__c> files = new List<SwiftSign_File__c>();

  for (ContentVersion contentVersion : Trigger.New) {
    if (string.isBlank(contentVersion.SwiftSignGuestUploadConfigJson__c))
      continue;

    SwiftSignHelper.GuestUploadConfig guestUploadConfig = SwiftSignHelper.GuestUploadConfigParse(
      contentVersion.SwiftSignGuestUploadConfigJson__c
    );

    if (guestUploadConfig == null)
      continue;

    string swiftSignFileId = guestUploadConfig.SwiftSignFileId;
    boolean makeItPublic = guestUploadConfig.MakeItPublic ?? false;
    boolean hasMoreRouting = guestUploadConfig.hasMoreRouting ?? true;
    List<string> linkedEntityIds = guestUploadConfig.LinkedEntityIds ??
      new List<string>();

    if (!string.isEmpty(swiftSignFileId) && swiftSignFileId instanceof Id) {
      files.add(
        new SwiftSign_File__c(
          Id = guestUploadConfig.SwiftSignFileId,
          Completed__c = !hasMoreRouting,
          Signed_Content_Document_Id__c = contentVersion.ContentDocumentId
        )
      );
    }

    for (string linkedEntityId : linkedEntityIds) {
      if (string.isEmpty(linkedEntityId) || !(linkedEntityId instanceof Id))
        continue;

      ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
      contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
      contentDocumentLink.LinkedEntityId = linkedEntityId;
      contentDocumentLink.ShareType = 'V'; // View access
      contentDocumentLink.Visibility = 'AllUsers';
      contentDocumentLinks.add(contentDocumentLink);
    }

    if (!makeItPublic)
      continue;

    ContentDistribution contentDistribution = new ContentDistribution();
    contentDistribution.ContentVersionId = contentVersion.Id;
    contentDistribution.Name = contentVersion.Title;
    contentDistribution.PreferencesAllowPDFDownload = true;
    contentDistribution.PreferencesAllowViewInBrowser = true;
    contentDistribution.PreferencesNotifyOnVisit = false;
    contentDistributions.add(contentDistribution);
  }

  if (!contentDocumentLinks.isEmpty()) {
    List<Database.SaveResult> cdlResults = Database.insert(
      contentDocumentLinks,
      false
    );
    for (Database.SaveResult sr : cdlResults) {
      if (!sr.isSuccess()) {
        System.debug(
          LoggingLevel.ERROR,
          'ContentDocumentLink insert failed: ' + sr.getErrors()
        );
      }
    }
  }
  if (!contentDistributions.isEmpty()) {
    List<Database.SaveResult> distResults = Database.insert(
      contentDistributions,
      false
    );
    for (Database.SaveResult sr : distResults) {
      if (!sr.isSuccess()) {
        System.debug(
          LoggingLevel.ERROR,
          'ContentDistribution insert failed: ' + sr.getErrors()
        );
      }
    }
  }
  if (!files.isEmpty()) {
    List<Database.SaveResult> fileResults = Database.update(files, false);
    for (Database.SaveResult sr : fileResults) {
      if (!sr.isSuccess()) {
        System.debug(
          LoggingLevel.ERROR,
          'SwiftSign_File__c update failed: ' + sr.getErrors()
        );
      }
    }
  }
}
