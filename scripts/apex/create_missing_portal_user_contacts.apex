// Creates one Contact for each explicitly reviewed Portal User and links it.
// The operation is atomic: any failure rolls back all Contact inserts and links.
Set<Id> targetPortalUserIds = new Set<Id>{
  'a0MHr00000MF3b1MAD',
  'a0MHr00000MF3WwMAL',
  'a0MHr00000MF3bBMAT',
  'a0Mg8000000a9hVEAQ',
  'a0MHr00000MF4UzMAL',
  'a0MHr00000MF3WuMAL',
  'a0Mg8000000ZxMzEAK',
  'a0MHr00000LcrNtMAJ',
  'a0MHr00000MF3quMAD',
  'a0MHr00000MF3qvMAD',
  'a0MHr00000MF3qwMAD',
  'a0MHr00000MF3phMAD',
  'a0MHr00000LcrNyMAJ'
};

Savepoint reconciliationSavepoint = Database.setSavepoint();
try {
  List<Portal_Users__c> portalUsers = [
    SELECT
      Id,
      Name,
      Email__c,
      User_Email__c,
      Phone__c,
      Department__c,
      Designation__c,
      Account__c,
      Contact__c
    FROM Portal_Users__c
    WHERE Id IN :targetPortalUserIds
    FOR UPDATE
  ];

  if (portalUsers.size() != targetPortalUserIds.size()) {
    throw new IllegalArgumentException(
      'Expected 13 reviewed Portal Users but found ' + portalUsers.size() + '.'
    );
  }

  Set<Id> existingContactIds = new Set<Id>();
  for (Portal_Users__c existingLink : [
    SELECT Contact__c
    FROM Portal_Users__c
    WHERE Contact__c != NULL
  ]) {
    existingContactIds.add(existingLink.Contact__c);
  }

  List<Contact> contactsToInsert = new List<Contact>();
  for (Portal_Users__c portalUser : portalUsers) {
    if (portalUser.Contact__c != null) {
      throw new IllegalArgumentException(
        'Portal User was linked after review: ' + portalUser.Id
      );
    }

    String fullName = String.isBlank(portalUser.Name)
      ? 'Portal User ' + portalUser.Id
      : portalUser.Name.trim();
    Integer firstSpace = fullName.indexOf(' ');
    String firstName = firstSpace > 0
      ? fullName.substring(0, firstSpace)
      : null;
    String lastName = firstSpace > 0
      ? fullName.substring(firstSpace + 1)
      : fullName;
    String employeeEmail = String.isNotBlank(portalUser.Email__c)
      ? portalUser.Email__c.trim()
      : (String.isNotBlank(portalUser.User_Email__c)
          ? portalUser.User_Email__c.trim()
          : null);

    // Some legacy Department/Designation values contain record IDs rather than labels.
    String department = String.isNotBlank(portalUser.Department__c) &&
      !portalUser.Department__c.startsWith('a0')
      ? portalUser.Department__c
      : null;
    String title = String.isNotBlank(portalUser.Designation__c) &&
      !portalUser.Designation__c.startsWith('a0')
      ? portalUser.Designation__c
      : null;

    contactsToInsert.add(
      new Contact(
        FirstName = firstName,
        LastName = lastName,
        Email = employeeEmail,
        Phone = portalUser.Phone__c,
        Department = department,
        Title = title,
        AccountId = portalUser.Account__c
      )
    );
  }

  insert contactsToInsert;

  List<Portal_Users__c> linksToUpdate = new List<Portal_Users__c>();
  for (Integer index = 0; index < portalUsers.size(); index++) {
    Contact createdContact = contactsToInsert[index];
    if (existingContactIds.contains(createdContact.Id)) {
      throw new IllegalArgumentException(
        'New Contact unexpectedly conflicts with an existing Portal User link.'
      );
    }
    linksToUpdate.add(
      new Portal_Users__c(
        Id = portalUsers[index].Id,
        Contact__c = createdContact.Id
      )
    );
  }
  update linksToUpdate;

  Integer verifiedLinks = [
    SELECT COUNT()
    FROM Portal_Users__c
    WHERE Id IN :targetPortalUserIds AND Contact__c != NULL
  ];
  if (verifiedLinks != targetPortalUserIds.size()) {
    throw new IllegalArgumentException(
      'Post-update verification failed. Expected 13 links but found ' +
        verifiedLinks +
        '.'
    );
  }

  System.debug(
    LoggingLevel.WARN,
    'PWCHRONO_CONTACT_CREATION_OK created=' +
      contactsToInsert.size() +
      ', linked=' +
      verifiedLinks
  );
} catch (Exception operationError) {
  Database.rollback(reconciliationSavepoint);
  System.debug(
    LoggingLevel.ERROR,
    'PWCHRONO_CONTACT_CREATION_ROLLED_BACK ' + operationError.getMessage()
  );
  throw operationError;
}
