/**
 * @description Security utility class for CRUD/FLS enforcement
 * This class provides methods to check object and field-level security
 * before performing DML operations.
 *
 * IMPORTANT: This class uses 'without sharing' to allow security checks
 * regardless of record-level access. The methods check CRUD/FLS only.
 *
 * @author PWChrono Team
 * @since December 2025
 */
public without sharing class PWChrono_SecurityUtils {
  // Whitelist of objects that Guest Users (Portal Users) are allowed to access via this utility.
  // This allows us to remove standard Profile permissions (locking down the org)
  // while permitting our specific Controllers to function.
  private static final Set<String> GUEST_SAFE_OBJECTS = new Set<String>{
    'Portal_Users__c',
    'PWChrono_Leave__c',
    'PWChrono_Leave_Type__c',
    'PWChrono_Leave_Allocation__c',
    'PWChrono_Attendance_Request__c',
    'PWChrono_Expense_Claim__c',
    'PWChrono_Expense_Item__c',
    'PWChrono_Salary_Slip__c',
    'PWChrono_Tax_Declaration__c',
    'PWChrono_Holiday__c',
    'PWChrono_Company_Policy__c',
    'PWChrono_Training_Program__c',
    'PWChrono_Training_Event__c',
    'PWChrono_Job_Opening__c',
    'PWChrono_Job_Applicant__c',
    'PWChrono_Designation__c',
    'PWChrono_Offer_Letter__c',
    'PWChrono_Appraisal__c',
    'PWChrono_Goal__c',
    'Account', // For company info
    'Contact', // For employee info
    'Opportunity' // For Projects Display
  };

  /**
   * @description Check if the user has read access to the object and fields (String version)
   * @param objName The API name of the object
   * @param fields List of field API names to check
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkRead(String objName, List<String> fields) {
    // 1. For Guest Users, check the dynamic permissions
    if (UserInfo.getUserType() == 'Guest') {
      return checkPortalPermission(objName, 'Read');
    }

    // 2. For Internal Users, use standard Salesforce security
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
    if (objType == null) {
      return false;
    }
    return checkRead(objType, fields);
  }

  /**
   * @description Check if the user has read access to the object and fields
   * @param objType The SObjectType to check
   * @param fields List of field API names to check
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkRead(
    Schema.SObjectType objType,
    List<String> fields
  ) {
    // 1. For Guest Users, check the dynamic permissions
    if (UserInfo.getUserType() == 'Guest') {
      return checkPortalPermission(String.valueOf(objType), 'Read');
    }

    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    if (!objDescribe.isAccessible()) {
      return false;
    }

    if (fields == null || fields.isEmpty()) {
      return true;
    }

    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    for (String fieldName : fields) {
      Schema.SObjectField field = fieldMap.get(fieldName.toLowerCase());
      if (field == null || !field.getDescribe().isAccessible()) {
        return false;
      }
    }
    return true;
  }

  /**
   * @description Check if the user has create access to the object and fields (String version)
   * @param objName The API name of the object
   * @param fields List of field API names to check
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkInsert(String objName, List<String> fields) {
    // 1. For Guest Users, check the dynamic permissions
    if (UserInfo.getUserType() == 'Guest') {
      return checkPortalPermission(objName, 'Create');
    }

    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
    if (objType == null) {
      return false;
    }
    return checkInsert(objType, fields);
  }

  /**
   * @description Check if the user has create access to the object and fields
   * @param objType The SObjectType to check
   * @param fields List of field API names to check
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkInsert(
    Schema.SObjectType objType,
    List<String> fields
  ) {
    // 1. For Guest Users, check the dynamic permissions
    if (UserInfo.getUserType() == 'Guest') {
      return checkPortalPermission(String.valueOf(objType), 'Create');
    }

    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    if (!objDescribe.isCreateable()) {
      return false;
    }

    if (fields == null || fields.isEmpty()) {
      return true;
    }

    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    for (String fieldName : fields) {
      Schema.SObjectField field = fieldMap.get(fieldName.toLowerCase());
      if (field == null || !field.getDescribe().isCreateable()) {
        return false;
      }
    }
    return true;
  }

  /**
   * @description Check if the user has update access to the object and fields (String version)
   * @param objName The API name of the object
   * @param fields List of field API names to check
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkUpdate(String objName, List<String> fields) {
    // 1. For Guest Users, check the dynamic permissions
    if (UserInfo.getUserType() == 'Guest') {
      return checkPortalPermission(objName, 'Edit');
    }

    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
    if (objType == null) {
      return false;
    }
    return checkUpdate(objType, fields);
  }

  /**
   * @description Check if the user has update access to the object and fields
   * @param objType The SObjectType to check
   * @param fields List of field API names to check
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkUpdate(
    Schema.SObjectType objType,
    List<String> fields
  ) {
    // 1. For Guest Users, check the dynamic permissions
    if (UserInfo.getUserType() == 'Guest') {
      return checkPortalPermission(String.valueOf(objType), 'Edit');
    }

    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    if (!objDescribe.isUpdateable()) {
      return false;
    }

    if (fields == null || fields.isEmpty()) {
      return true;
    }

    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    for (String fieldName : fields) {
      Schema.SObjectField field = fieldMap.get(fieldName.toLowerCase());
      if (field == null || !field.getDescribe().isUpdateable()) {
        return false;
      }
    }
    return true;
  }

  /**
   * @description Check if the user has delete access to the object (String version)
   * @param objName The API name of the object
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkDelete(String objName) {
    // 1. For Guest Users, check the dynamic permissions
    if (UserInfo.getUserType() == 'Guest') {
      return checkPortalPermission(objName, 'Delete');
    }

    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
    if (objType == null) {
      return false;
    }
    return checkDelete(objType);
  }

  /**
   * @description Check if the user has delete access to the object
   * @param objType The SObjectType to check
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkDelete(Schema.SObjectType objType) {
    // 1. For Guest Users, check the dynamic permissions
    if (UserInfo.getUserType() == 'Guest') {
      return checkPortalPermission(String.valueOf(objType), 'Delete');
    }

    return objType.getDescribe().isDeletable();
  }

  /**
   * @description Check if user can perform upsert (insert or update) on the object
   * @param objType The SObjectType to check
   * @param fields List of field API names to check
   * @param isInsert Whether this is an insert (true) or update (false)
   * @return Boolean true if access is granted, false otherwise
   */
  public static Boolean checkUpsert(
    Schema.SObjectType objType,
    List<String> fields,
    Boolean isInsert
  ) {
    return isInsert
      ? checkInsert(objType, fields)
      : checkUpdate(objType, fields);
  }

  /**
   * @description Helper to check dynamic permissions for Portal Users
   * @param objName The API name of the object
   * @param accessType The type of access (Read, Create, Edit, Delete)
   * @return Boolean true if access is granted
   */
  private static Boolean checkPortalPermission(
    String objName,
    String accessType
  ) {
    // 1. Fallback to whitelist if no user context (e.g. during login/registration)
    // or if the object is always safe (like Portal_Users__c itself)
    if (
      GUEST_SAFE_OBJECTS.contains(objName) &&
      (objName == 'Portal_Users__c' ||
      objName == 'Account' ||
      objName == 'Contact')
    ) {
      return true;
    }

    // 2. Get Current Portal User
    // We need to get the Portal User ID from the session or context.
    // Since this is a static utility, we rely on PWChrono_Utils or AuthController.
    // However, for this implementation, we'll query based on the Salesforce User ID
    // which maps to the Portal User.

    // Note: This query runs 'without sharing' so it can see the Portal User record
    List<Portal_Users__c> users = [
      SELECT Id, Portal_User_Profile__c
      FROM Portal_Users__c
      WHERE User__c = :UserInfo.getUserId()
      LIMIT 1
    ];

    if (users.isEmpty() || users[0].Portal_User_Profile__c == null) {
      // If no portal user or no profile assigned, deny access (unless it was a safe object handled above)
      // Fallback to whitelist for backward compatibility during migration
      return GUEST_SAFE_OBJECTS.contains(objName);
    }

    Id profileId = users[0].Portal_User_Profile__c;

    // 3. Check Permissions
    // We query the permission record for this profile and object
    List<Portal_Object_Permission__c> perms = [
      SELECT Can_View__c, Can_Create__c, Can_Edit__c, Can_Delete__c
      FROM Portal_Object_Permission__c
      WHERE
        Portal_User_Profile__c = :profileId
        AND (Portal_Object__r.Object_API_Name__c = :objName
        OR Portal_Object__r.Name = :objName)
      LIMIT 1
    ];

    if (perms.isEmpty()) {
      return false;
    }

    Portal_Object_Permission__c perm = perms[0];

    if (accessType == 'Read')
      return perm.Can_View__c;
    if (accessType == 'Create')
      return perm.Can_Create__c;
    if (accessType == 'Edit')
      return perm.Can_Edit__c;
    if (accessType == 'Delete')
      return perm.Can_Delete__c;

    return false;
  }
}
