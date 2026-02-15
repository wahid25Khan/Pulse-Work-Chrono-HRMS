/**
 * @description Utility for validating a portal user's session in Guest runtime.
 *              This keeps Guest DML possible while ensuring the caller proves
 *              they have a valid, server-issued session token.
 */
public without sharing class PWChrono_GuestSession {
  /**
   * @description Resolve the effective portal user Id for the current context.
   *              - Non-Guest: uses provided portalUserId if present, otherwise maps current Salesforce user.
   *              - Guest: requires portalUserId + sessionToken and validates against Portal_Users__c.
   */
  public static Id requireVerifiedPortalUserId(String portalUserId, String sessionToken) {
    // Internal Salesforce users or authenticated Experience users.
    if (UserInfo.getUserType() != 'Guest') {
      if (String.isNotBlank(portalUserId)) {
        return (Id) portalUserId;
      }
      return PWChrono_Utils.getCurrentEmployeeId(UserInfo.getUserId());
    }

    // Guest runtime MUST prove identity with a server-issued token.
    if (String.isBlank(portalUserId) || String.isBlank(sessionToken)) {
      throw new AuraHandledException('Session invalid or expired. Please log in again.');
    }

    Id pid;
    try {
      pid = (Id) portalUserId;
    } catch (Exception e) {
      throw new AuraHandledException('Session invalid.');
    }

    List<Portal_Users__c> users = [
      SELECT Id, Is_Active__c, Session_Token__c, Session_Expires_At__c
      FROM Portal_Users__c
      WHERE Id = :pid
      LIMIT 1
    ];

    if (users.isEmpty()) {
      throw new AuraHandledException('Session invalid.');
    }

    Portal_Users__c u = users[0];
    if (u.Is_Active__c != true) {
      throw new AuraHandledException('Account is inactive.');
    }

    if (String.isBlank(u.Session_Token__c) || u.Session_Expires_At__c == null) {
      throw new AuraHandledException('Session expired. Please log in again.');
    }

    if (u.Session_Expires_At__c <= System.now()) {
      throw new AuraHandledException('Session expired. Please log in again.');
    }

    if (u.Session_Token__c != sessionToken) {
      throw new AuraHandledException('Session invalid. Please log in again.');
    }

    return u.Id;
  }
}