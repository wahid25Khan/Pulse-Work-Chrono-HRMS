// Link the final Portal User login to its existing canonical employee Contact.
// Multiple login/access records may reference the same Contact, preserving one
// employee master and one current bank-information record.
Id targetPortalUserId = 'a0Mg8000000ZxLNEA0';
Savepoint linkSavepoint = Database.setSavepoint();

try {
  Portal_Users__c portalUser = [
    SELECT Id, Name, Email__c, User_Email__c, Contact__c
    FROM Portal_Users__c
    WHERE Id = :targetPortalUserId
    LIMIT 1
    FOR UPDATE
  ];

  if (portalUser.Contact__c != null) {
    throw new IllegalArgumentException(
      'Portal User is already linked to Contact ' + portalUser.Contact__c + '.'
    );
  }

  String employeeEmail = String.isNotBlank(portalUser.Email__c)
    ? portalUser.Email__c.trim()
    : portalUser.User_Email__c;
  List<Contact> candidates = [
    SELECT Id, Name, Email
    FROM Contact
    WHERE Email = :employeeEmail
  ];
  if (candidates.size() != 1) {
    throw new IllegalArgumentException(
      'Expected one exact-email Contact but found ' + candidates.size() + '.'
    );
  }

  Contact canonicalContact = candidates[0];
  portalUser.Contact__c = canonicalContact.Id;
  update portalUser;

  Portal_Users__c verified = [
    SELECT Contact__c, Contact__r.Name, Contact__r.Email
    FROM Portal_Users__c
    WHERE Id = :targetPortalUserId
  ];
  if (
    verified.Contact__c != canonicalContact.Id ||
    verified.Contact__r.Email != employeeEmail
  ) {
    throw new IllegalArgumentException('Contact link verification failed.');
  }

  System.debug(
    LoggingLevel.WARN,
    'PWCHRONO_FINAL_CONTACT_LINK_OK portalUser=' +
      targetPortalUserId +
      ', contact=' +
      canonicalContact.Id
  );
} catch (Exception operationError) {
  Database.rollback(linkSavepoint);
  System.debug(
    LoggingLevel.ERROR,
    'PWCHRONO_FINAL_CONTACT_LINK_ROLLED_BACK ' + operationError.getMessage()
  );
  throw operationError;
}
