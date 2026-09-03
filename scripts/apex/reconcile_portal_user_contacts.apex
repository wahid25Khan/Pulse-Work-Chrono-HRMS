// Safe one-time reconciliation for Portal_Users__c.Contact__c.
// The script matches only a unique normalized email and refuses ambiguous or
// already-claimed Contacts. Review the dry-run output before setting this true.
Boolean applyChanges = false;

List<Portal_Users__c> portalUsers = [
  SELECT Id, Name, Email__c, User_Email__c, Contact__c, Contact__r.Email
  FROM Portal_Users__c
  ORDER BY Name
];
List<Contact> contacts = [
  SELECT Id, Name, Email
  FROM Contact
  WHERE Email != NULL
  ORDER BY Name
];

Map<String, List<Contact>> contactsByEmail = new Map<String, List<Contact>>();
for (Contact contactRecord : contacts) {
  String emailKey = contactRecord.Email.trim().toLowerCase();
  if (!contactsByEmail.containsKey(emailKey)) {
    contactsByEmail.put(emailKey, new List<Contact>());
  }
  contactsByEmail.get(emailKey).add(contactRecord);
}

Map<Id, Id> contactOwnerByPortalUser = new Map<Id, Id>();
for (Portal_Users__c portalUser : portalUsers) {
  if (portalUser.Contact__c != null) {
    contactOwnerByPortalUser.put(portalUser.Contact__c, portalUser.Id);
  }
}

List<Portal_Users__c> safeUpdates = new List<Portal_Users__c>();
List<String> unresolved = new List<String>();
List<String> ambiguous = new List<String>();
List<String> conflicts = new List<String>();
Integer alreadyLinked = 0;

for (Portal_Users__c portalUser : portalUsers) {
  if (portalUser.Contact__c != null) {
    alreadyLinked++;
    continue;
  }

  String employeeEmail = String.isNotBlank(portalUser.Email__c)
    ? portalUser.Email__c
    : portalUser.User_Email__c;
  if (String.isBlank(employeeEmail)) {
    unresolved.add(portalUser.Id + ' | ' + portalUser.Name + ' | no email');
    continue;
  }

  String emailKey = employeeEmail.trim().toLowerCase();
  List<Contact> candidates = contactsByEmail.get(emailKey);
  if (candidates == null || candidates.isEmpty()) {
    unresolved.add(
      portalUser.Id + ' | ' + portalUser.Name + ' | no Contact email match'
    );
    continue;
  }
  if (candidates.size() != 1) {
    ambiguous.add(
      portalUser.Id +
        ' | ' +
        portalUser.Name +
        ' | ' +
        candidates.size() +
        ' Contact matches'
    );
    continue;
  }

  Contact candidate = candidates[0];
  if (
    contactOwnerByPortalUser.containsKey(candidate.Id) &&
    contactOwnerByPortalUser.get(candidate.Id) != portalUser.Id
  ) {
    conflicts.add(
      portalUser.Id + ' | ' + portalUser.Name + ' | Contact already linked'
    );
    continue;
  }

  safeUpdates.add(
    new Portal_Users__c(Id = portalUser.Id, Contact__c = candidate.Id)
  );
  contactOwnerByPortalUser.put(candidate.Id, portalUser.Id);
}

System.debug(
  LoggingLevel.WARN,
  'PWCHRONO_CONTACT_RECONCILIATION applyChanges=' + applyChanges
);
System.debug(
  LoggingLevel.WARN,
  'alreadyLinked=' + alreadyLinked + ', safeUniqueMatches=' + safeUpdates.size()
);
System.debug(
  LoggingLevel.WARN,
  'unresolved=' + JSON.serializePretty(unresolved)
);
System.debug(LoggingLevel.WARN, 'ambiguous=' + JSON.serializePretty(ambiguous));
System.debug(LoggingLevel.WARN, 'conflicts=' + JSON.serializePretty(conflicts));

if (applyChanges && !safeUpdates.isEmpty()) {
  update safeUpdates;
  System.debug(
    LoggingLevel.WARN,
    'UPDATED_PORTAL_USER_CONTACT_LINKS=' + safeUpdates.size()
  );
} else {
  System.debug(LoggingLevel.WARN, 'DRY_RUN_ONLY_NO_DML');
}
