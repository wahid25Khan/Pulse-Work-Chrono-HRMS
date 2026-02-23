/**
 * @description Controller for Expense Claim LWC Components
 * @author PWChrono Team
 */
public inherited sharing class PWChrono_ExpenseController {
  /**
   * @description Get expense claims for current employee
   * @param employeeId Optional employee ID (Portal_Users__c). If null, uses current user's employee record.
   * @return List of expense claims
   */
  @AuraEnabled(cacheable=true)
  public static List<PWChrono_Expense_Claim__c> getMyClaims(
    String employeeId,
    String sessionToken
  ) {
    try {
      Id targetEmployeeId;
      if (UserInfo.getUserType() == 'Guest') {
        targetEmployeeId = PWChrono_GuestSession.requireVerifiedPortalUserId(
          employeeId,
          sessionToken
        );
      } else if (String.isNotBlank(employeeId)) {
        Id currentEmployeeId = PWChrono_Utils.getCurrentEmployeeId(
          UserInfo.getUserId()
        );
        if (currentEmployeeId != null && employeeId != currentEmployeeId) {
          if (PWChrono_AccessController.isAdmin(currentEmployeeId)) {
            targetEmployeeId = (Id) employeeId;
          } else {
            targetEmployeeId = currentEmployeeId;
          }
        } else {
          targetEmployeeId = (Id) employeeId;
        }
      } else {
        targetEmployeeId = PWChrono_Utils.getCurrentEmployeeId(
          UserInfo.getUserId()
        );
      }

      if (targetEmployeeId == null) {
        throw new AuraHandledException(
          'No employee record found for current user.'
        );
      }

      return [
        SELECT
          Id,
          Name,
          Claim_Date__c,
          Description__c,
          Total_Amount__c,
          Status__c,
          CreatedDate
        FROM PWChrono_Expense_Claim__c
        WHERE Employees__c = :targetEmployeeId
        ORDER BY CreatedDate DESC
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('Error fetching expense claims: ');
      PWChrono_Logger.error('Stack trace: ' + e.getStackTraceString());
      AuraHandledException ahe = new AuraHandledException(
        'Error fetching expense claims: '
      );
      ahe.setMessage('Error fetching expense claims: ');
      throw ahe;
    }
  }

  /**
   * @description Get items for a specific claim
   * @param claimId Claim ID
   * @return List of expense items
   */
  @AuraEnabled(cacheable=false)
  public static List<PWChrono_Expense_Item__c> getClaimItems(
    Id claimId,
    String portalUserId,
    String sessionToken
  ) {
    try {
      if (UserInfo.getUserType() == 'Guest') {
        Id verifiedPortalUserId = PWChrono_GuestSession.requireVerifiedPortalUserId(
          portalUserId,
          sessionToken
        );
        List<PWChrono_Expense_Claim__c> claims = [
          SELECT Employees__c
          FROM PWChrono_Expense_Claim__c
          WHERE Id = :claimId
          LIMIT 1
        ];
        if (
          claims.isEmpty() || claims[0].Employees__c != verifiedPortalUserId
        ) {
          throw new AuraHandledException('Access Denied.');
        }
      }

      return [
        SELECT Id, Date__c, Type__c, Amount__c, Description__c
        FROM PWChrono_Expense_Item__c
        WHERE Expense_Claim__c = :claimId
        ORDER BY Date__c ASC
      ];
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error fetching claim items: '
      );
      ahe.setMessage('Error fetching claim items: ');
      throw ahe;
    }
  }

  /**
   * @description Save Expense Claim and Items
   * @param claim Claim record
   * @param items List of Item records
   * @return Saved Claim
   */
  @AuraEnabled
  public static PWChrono_Expense_Claim__c saveClaim(
    PWChrono_Expense_Claim__c claim,
    List<PWChrono_Expense_Item__c> items,
    String portalUserId,
    String sessionToken
  ) {
    try {
      Id verifiedPortalUserId = PWChrono_GuestSession.requireVerifiedPortalUserId(
        portalUserId,
        sessionToken
      );

      // Always enforce ownership on the server.
      claim.Employees__c = verifiedPortalUserId;
      return PWChrono_ExpenseService.saveClaim(claim, items);
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error saving expense claim: '
      );
      ahe.setMessage('Error saving expense claim: ');
      throw ahe;
    }
  }

  /**
   * @description Submit Claim for approval
   * @param claimId Record ID
   */
  @AuraEnabled
  public static void submitClaim(
    Id claimId,
    String portalUserId,
    String sessionToken
  ) {
    try {
      Id verifiedPortalUserId = PWChrono_GuestSession.requireVerifiedPortalUserId(
        portalUserId,
        sessionToken
      );
      PWChrono_ExpenseService.submitClaim(claimId, verifiedPortalUserId);
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error submitting claim: '
      );
      ahe.setMessage('Error submitting claim: ');
      throw ahe;
    }
  }

  /**
   * @description Delete Claim
   * @param claimId Record ID
   */
  @AuraEnabled
  public static void deleteClaim(
    Id claimId,
    String portalUserId,
    String sessionToken
  ) {
    try {
      Id verifiedPortalUserId = PWChrono_GuestSession.requireVerifiedPortalUserId(
        portalUserId,
        sessionToken
      );
      PWChrono_ExpenseService.deleteClaim(claimId, verifiedPortalUserId);
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      AuraHandledException ahe = new AuraHandledException(
        'Error deleting claim: '
      );
      ahe.setMessage('Error deleting claim: ');
      throw ahe;
    }
  }
}
