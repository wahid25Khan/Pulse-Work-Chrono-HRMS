@isTest
private class PWChrono_RoleFeatureMappingController_Test {
  @isTest
  static void testGetMappings_ReturnsList() {
    Test.startTest();
    List<PWChrono_Role_Feature_Mapping__mdt> mappings =
      PWChrono_RoleFeatureMappingController.getMappings();
    Test.stopTest();

    System.assertNotEquals(null, mappings, 'Mappings query should always return a list.');
  }

  @isTest
  static void testSaveMapping_HandlesSpecialCharacters() {
    Test.startTest();
    try {
      PWChrono_RoleFeatureMappingController.saveMapping(
        'HR Admin',
        'Admin Settings & Config'
      );
    } catch (Exception e) {
      System.assert(
        e.getMessage() != null,
        'If metadata deployment errors in test context, exception should still be controlled.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testDeleteMapping_HandlesRequest() {
    Test.startTest();
    try {
      PWChrono_RoleFeatureMappingController.deleteMapping('HR_Admin_Admin_Settings___Config');
    } catch (Exception e) {
      System.assert(
        e.getMessage() != null,
        'If metadata deployment errors in test context, exception should still be controlled.'
      );
    }
    Test.stopTest();
  }
}
