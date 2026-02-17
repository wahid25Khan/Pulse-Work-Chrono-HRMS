/**
 * @description Helper class for sending emails
 * @author PWChrono Team
 */
public inherited sharing class PWChrono_EmailHandler {
  public static void sendAppraisalNotifications(
    List<PWChrono_Appraisal__c> appraisals
  ) {
    Set<Id> appraisalIds = new Set<Id>();
    for (PWChrono_Appraisal__c app : appraisals) {
      appraisalIds.add(app.Id);
    }

    // Fetch Notification Recipients
    List<PWChrono_Appraisal_Notification__c> recipients = [
      SELECT
        Id,
        Appraisal__c,
        Portal_User__c,
        Portal_User__r.Email__c,
        Email__c,
        Role__c
      FROM PWChrono_Appraisal_Notification__c
      WHERE Appraisal__c IN :appraisalIds
    ];

    if (recipients.isEmpty()) {
      return;
    }

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (PWChrono_Appraisal_Notification__c recipient : recipients) {
      String emailAddress = recipient.Email__c;
      if (String.isBlank(emailAddress) && recipient.Portal_User__c != null) {
        emailAddress = recipient.Portal_User__r.Email__c;
      }

      if (String.isNotBlank(emailAddress)) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ emailAddress });
        mail.setSubject('Appraisal Update Notification');
        mail.setPlainTextBody(
          'An appraisal you are following has been updated. Role: ' +
          recipient.Role__c
        );
        // In a real scenario, you would use an Email Template
        emails.add(mail);
      }
    }

    if (!emails.isEmpty()) {
      Messaging.sendEmail(emails);
    }
  }
}