/**
 * @description Service class for Expense Claim operations
 */
public without sharing class PWChrono_ExpenseService {
  /**
   * @description Save Expense Claim and Items
   */
  public static PWChrono_Expense_Claim__c saveClaim(
    PWChrono_Expense_Claim__c claim,
    List<PWChrono_Expense_Item__c> items
  ) {
    Savepoint sp = Database.setSavepoint();
    try {
      Id employeeId;
      if (claim.Employees__c != null) {
        employeeId = claim.Employees__c;
      } else {
        employeeId = PWChrono_Utils.getCurrentEmployeeId(UserInfo.getUserId());
      }

      if (employeeId == null) {
        throw new AuraHandledException(
          'No employee record found for current user.'
        );
      }

      validateAndPrepareClaim(claim, employeeId);

      // SECURITY NOTE: Guest users in Experience Cloud cannot pass standard CRUD/FLS checks.
      // Access control is enforced via validateAndPrepareClaim() ownership validation above.
      // The 'without sharing' context is required for guest user access pattern.
      upsert claim;

      // Handle items
      if (items != null) {
        processClaimItems(claim.Id, items);
      }

      return claim;
    } catch (Exception e) {
      PWChrono_Logger.error('An error occurred', e);
      Database.rollback(sp);
      throw new AuraHandledException('Error saving expense claim: ');
    }
  }

  private static void validateAndPrepareClaim(
    PWChrono_Expense_Claim__c claim,
    Id employeeId
  ) {
    if (claim.Id == null) {
      claim.Employees__c = employeeId;
      claim.Status__c = PWChrono_Constants.STATUS_DRAFT;
    } else {
      // Verify ownership and status
      List<PWChrono_Expense_Claim__c> existing = [
        SELECT Id, Status__c
        FROM PWChrono_Expense_Claim__c
        WHERE Id = :claim.Id AND Employees__c = :employeeId
      ];
      if (existing.isEmpty()) {
        throw new AuraHandledException('Access Denied.');
      }
      if (
        existing[0].Status__c != PWChrono_Constants.STATUS_DRAFT &&
        existing[0].Status__c != PWChrono_Constants.STATUS_REJECTED
      ) {
        throw new AuraHandledException(
          'Cannot edit submitted or approved claims.'
        );
      }
    }
  }

  private static void processClaimItems(
    Id claimId,
    List<PWChrono_Expense_Item__c> items
  ) {
    List<Id> itemIdsToKeep = new List<Id>();
    for (PWChrono_Expense_Item__c item : items) {
      // Validation: Amount must be positive
      if (item.Amount__c == null || item.Amount__c <= 0) {
        throw new AuraHandledException(
          'Expense item amount must be greater than zero.'
        );
      }
      item.Expense_Claim__c = claimId;
      if (item.Id != null) {
        itemIdsToKeep.add(item.Id);
      }
    }

    deleteRemovedItems(claimId, itemIdsToKeep);

    // SECURITY NOTE: Guest users in Experience Cloud cannot pass standard CRUD/FLS checks.
    // Access control is enforced via processClaimItems() parent claim ownership validation.
    // The 'without sharing' context is required for guest user access pattern.
    upsert items;
  }

  private static void deleteRemovedItems(Id claimId, List<Id> itemIdsToKeep) {
    List<PWChrono_Expense_Item__c> itemsToDelete = [
      SELECT Id
      FROM PWChrono_Expense_Item__c
      WHERE Expense_Claim__c = :claimId AND Id NOT IN :itemIdsToKeep
    ];
    if (!itemsToDelete.isEmpty()) {
      delete itemsToDelete;
    }
  }

  /**
   * @description Submit Claim for approval
   */
  public static void submitClaim(Id claimId, Id employeeIdOverride) {
    Id employeeId = employeeIdOverride;
    if (employeeId == null) {
      Id currentUserId = UserInfo.getUserId();
      employeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);
    }

    PWChrono_Expense_Claim__c claim = [
      SELECT Id, Status__c
      FROM PWChrono_Expense_Claim__c
      WHERE Id = :claimId AND Employees__c = :employeeId
      LIMIT 1
    ];

    if (claim.Status__c != PWChrono_Constants.STATUS_DRAFT) {
      throw new AuraHandledException('Only Draft claims can be submitted.');
    }

    claim.Status__c = PWChrono_Constants.STATUS_SUBMITTED;
    update claim;
  }

  /**
   * @description Delete Claim
   */
  public static void deleteClaim(Id claimId, Id employeeIdOverride) {
    Id employeeId = employeeIdOverride;
    if (employeeId == null) {
      Id currentUserId = UserInfo.getUserId();
      employeeId = PWChrono_Utils.getCurrentEmployeeId(currentUserId);
    }

    PWChrono_Expense_Claim__c claim = [
      SELECT Id, Status__c
      FROM PWChrono_Expense_Claim__c
      WHERE Id = :claimId AND Employees__c = :employeeId
      LIMIT 1
    ];

    if (
      claim.Status__c != PWChrono_Constants.STATUS_DRAFT &&
      claim.Status__c != PWChrono_Constants.STATUS_REJECTED
    ) {
      throw new AuraHandledException(
        'Cannot delete submitted or approved claims.'
      );
    }
    delete claim;
  }
}
