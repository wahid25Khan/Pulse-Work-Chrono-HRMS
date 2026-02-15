/**
 * @description Debug utility for testing portal functionality
 * @author PWChrono Team
 */
public without sharing class PWChrono_DebugUtil {
  /**
   * @description Get comprehensive system debug information
   * @return Map with debug data
   */
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> getDebugInfo() {
    Map<String, Object> debugInfo = new Map<String, Object>();

    try {
      // Security Check: Debug utility should only be available to Salesforce internal users.
      // (The Debug Panel can be toggled via URL param and must not be exposed to portal/guest contexts.)
      if (!PWChrono_AccessController.isSalesforceInternalUser()) {
        throw new AuraHandledException('Access Denied: Admin privileges required.');
      }

      // Current user info
      Id currentUserId = UserInfo.getUserId();
      debugInfo.put('currentUserId', currentUserId);

      // Portal user info
      List<Portal_Users__c> portalUsers = [
        SELECT
          Id,
          Name,
          Email__c,
          User__c,
          Role__c,
          Is_Active__c,
          OTP_Generated_Time__c
        FROM Portal_Users__c
        WHERE User__c = :currentUserId
      ];
      debugInfo.put('portalUsers', portalUsers);

      // Feature access count
      if (!portalUsers.isEmpty()) {
        Integer featureCount = [
          SELECT COUNT()
          FROM PWChrono_User_Feature_Access__c
          WHERE Portal_User__c = :portalUsers[0].Id
        ];
        debugInfo.put('totalFeatureAccess', featureCount);

        // Active features
        List<PWChrono_User_Feature_Access__c> activeFeatures = [
          SELECT Feature_Name__c, Access_Level__c, Is_Active__c
          FROM PWChrono_User_Feature_Access__c
          WHERE Portal_User__c = :portalUsers[0].Id AND Is_Active__c = TRUE
        ];
        debugInfo.put('activeFeatures', activeFeatures);
      }

      // All available features in system
      Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.PWChrono_User_Feature_Access__c.fields.getMap();
      List<Schema.PicklistEntry> picklistValues = fieldMap.get(
          'Feature_Name__c'
        )
        .getDescribe()
        .getPicklistValues();
      List<String> features = new List<String>();
      for (Schema.PicklistEntry entry : picklistValues) {
        features.add(entry.getValue());
      }
      debugInfo.put('availableFeatures', features);

      // All portal users count
      Integer totalPortalUsers = [SELECT COUNT() FROM Portal_Users__c];
      debugInfo.put('totalPortalUsers', totalPortalUsers);
    } catch (Exception e) {
      debugInfo.put('error', e.getMessage());
    }

    return debugInfo;
  }

  /**
   * @description Test OTP generation and send
   * @param email User email
   * @return Map with test results
   */
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> testOTPSend(String email) {
    Map<String, Object> result = new Map<String, Object>();

    try {
      // Security Check: Debug utility should only be available to Salesforce internal users.
      if (!PWChrono_AccessController.isSalesforceInternalUser()) {
        throw new AuraHandledException('Access Denied: Admin privileges required.');
      }

      result.put('step1_findUser', 'Finding user with email: ' + email);
      Portal_Users__c user = [
        SELECT Id, Name, Email__c, OTP_Generated_Time__c, One_Time_Password__c
        FROM Portal_Users__c
        WHERE Email__c = :email
        LIMIT 1
      ];
      result.put(
        'step2_userFound',
        new Map<String, String>{
          'Id' => user.Id,
          'Name' => user.Name,
          'Email' => user.Email__c
        }
      );

      result.put('step3_generateOTP', 'Generating OTP...');
      Integer randomInt = Crypto.getRandomInteger();
      String otp = String.valueOf(
        Math.mod(Math.abs(randomInt), 900000) + 100000
      );
      result.put(
        'step4_otpGenerated',
        'OTP: ' + otp + ' (Length: ' + otp.length() + ')'
      );

      result.put('step5_sendingEmail', 'Email recipient: ' + email);
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(new List<String>{ email });
      mail.setSubject('TEST: Your Login OTP for PWChrono');
      mail.setPlainTextBody(
        'TEST OTP: ' +
          otp +
          '\n\nThis OTP is valid for 10 minutes.\n\nIf you did not request this OTP, please ignore this email.'
      );

      Messaging.SendEmailResult[] results = Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ mail }
      );
      result.put('step6_emailSent', results[0].isSuccess());

      if (!results[0].isSuccess()) {
        List<String> errors = new List<String>();
        try {
          List<Object> errorList = (List<Object>) results[0].getErrors();
          errors.add('Email send failed with errors');
        } catch (Exception e) {
          errors.add('Error details: ' + e.getMessage());
        }
        result.put('step7_emailErrors', errors);
      }

      result.put('success', true);
    } catch (Exception e) {
      result.put('success', false);
      result.put('error', e.getMessage());
      result.put('errorType', e.getTypeName());
    }

    return result;
  }

  /**
   * @description Test feature access assignment
   * @param portalUserId User ID
   * @param featureName Feature to assign
   * @return Map with test results
   */
  @AuraEnabled(cacheable=false)
  public static Map<String, Object> testFeatureAssignment(
    String portalUserId,
    String featureName
  ) {
    Map<String, Object> result = new Map<String, Object>();

    try {
      // Security Check: Only Admins can access debug info
      Map<String, Object> userAccess = PWChrono_AccessController.getUserAccess();
      String role = (String)userAccess.get('role');
      Boolean isSalesforceUser = (Boolean)userAccess.get('isSalesforceUser');
      
      if (isSalesforceUser != true && role != 'HR Admin' && role != 'System Admin') {
        throw new AuraHandledException('Access Denied: Admin privileges required.');
      }

      result.put(
        'step1_checkPortalUser',
        'Checking portal user: ' + portalUserId
      );
      Portal_Users__c user = [
        SELECT Id, Name
        FROM Portal_Users__c
        WHERE Id = :portalUserId
        LIMIT 1
      ];
      result.put('step2_userFound', user.Name);

      result.put(
        'step3_checkExistingAccess',
        'Looking for existing access record...'
      );
      List<PWChrono_User_Feature_Access__c> existing = [
        SELECT Id, Feature_Name__c, Is_Active__c
        FROM PWChrono_User_Feature_Access__c
        WHERE Portal_User__c = :portalUserId AND Feature_Name__c = :featureName
        LIMIT 1
      ];

      PWChrono_User_Feature_Access__c access;
      if (existing.isEmpty()) {
        result.put(
          'step4_creating',
          'Creating new access record for feature: ' + featureName
        );
        access = new PWChrono_User_Feature_Access__c(
          Portal_User__c = portalUserId,
          Feature_Name__c = featureName,
          Access_Level__c = 'Full Access',
          Is_Active__c = true
        );
        insert access;
        result.put('step5_inserted', 'New record created: ' + access.Id);
      } else {
        result.put('step4_updating', 'Updating existing access record...');
        access = existing[0];
        access.Is_Active__c = true;
        access.Access_Level__c = 'Full Access';
        update access;
        result.put('step5_updated', 'Record updated: ' + access.Id);
      }

      // Verify
      PWChrono_User_Feature_Access__c verified = [
        SELECT Id, Feature_Name__c, Access_Level__c, Is_Active__c
        FROM PWChrono_User_Feature_Access__c
        WHERE Id = :access.Id
        LIMIT 1
      ];
      result.put(
        'step6_verified',
        new Map<String, Object>{
          'Id' => verified.Id,
          'Feature' => verified.Feature_Name__c,
          'AccessLevel' => verified.Access_Level__c,
          'IsActive' => verified.Is_Active__c
        }
      );

      result.put('success', true);
    } catch (Exception e) {
      result.put('success', false);
      result.put('error', e.getMessage());
      result.put('errorType', e.getTypeName());
    }

    return result;
  }

  /**
   * @description Get all available test users
   * @return List of portal users
   */
  @AuraEnabled(cacheable=false)
  public static List<Map<String, String>> getTestUsers() {
    List<Map<String, String>> testUsers = new List<Map<String, String>>();

    try {
      // Security Check: Only Admins can access debug info
      Map<String, Object> access = PWChrono_AccessController.getUserAccess();
      String role = (String)access.get('role');
      Boolean isSalesforceUser = (Boolean)access.get('isSalesforceUser');
      
      if (isSalesforceUser != true && role != 'HR Admin' && role != 'System Admin') {
        throw new AuraHandledException('Access Denied: Admin privileges required.');
      }

      List<Portal_Users__c> users = [
        SELECT Id, Name, Email__c, Is_Active__c
        FROM Portal_Users__c
        ORDER BY Name
        LIMIT 50
      ];

      for (Portal_Users__c user : users) {
        testUsers.add(
          new Map<String, String>{
            'Id' => user.Id,
            'Name' => user.Name,
            'Email' => user.Email__c != null ? user.Email__c : 'N/A',
            'Active' => String.valueOf(user.Is_Active__c)
          }
        );
      }
    } catch (Exception e) {
      // Return empty list on error
    }

    return testUsers;
  }
}