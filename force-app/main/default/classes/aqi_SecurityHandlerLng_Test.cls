/**
* @author Altimetrik
* @description
*	started on January 2018
*   Test class the aqi_LightningResponse
**/
@isTest
private class aqi_SecurityHandlerLng_Test {
    @isTest static void allRecordTypes_test() {
        if (aqi_SecurityHandlerLng.checkForSchemaFieldActive('recordtypeid')) {
            System.Test.startTest();
            List<Object> result = aqi_SecurityHandlerLng.allRecordTypes;
            System.Test.stopTest();

            System.assertNotEquals(null, result.size(), 'The list should have at least a record');
        }
    }

    @isTest static void getLabelLanguage() {
        System.Test.startTest();
        String labelLanguage = aqi_SecurityHandlerLng.getLabelLanguage('en_US');
        System.Test.stopTest();

        System.assertNotEquals('', labelLanguage, 'The returned language should be distinct from empty');
    }
    @isTest static void getAllowedRecordTypes_test() {
        if (aqi_SecurityHandlerLng.checkForSchemaFieldActive('recordtypeid')) {
            String result = '';
            System.Test.startTest();
            result = aqi_SecurityHandlerLng.getAllowedRecordTypes();
            System.Test.stopTest();

            System.assertNotEquals('', result, 'The string should have at least a recordType');
        }
    }
    
    @isTest static void getAllowedRecordTypesMap_test() {
        if (aqi_SecurityHandlerLng.checkForSchemaFieldActive('recordtypeid')) {
            System.Test.startTest();
            Map<Id,String> all = aqi_SecurityHandlerLng.getAllowedRecordTypesMap() ;
            System.Test.stopTest();

            System.assertNotEquals(null, all, 'The Record Type Map should not be null');
        }
    }
 
    @isTest static void getAllowedRecordTypeNameToIdMap_test() {
        if (aqi_SecurityHandlerLng.checkForSchemaFieldActive('recordtypeid')) {
            System.Test.startTest();
            Map<String,Id> all = aqi_SecurityHandlerLng.getAllowedRecordTypeNameToIdMap();
            System.Test.stopTest();

            System.assertNotEquals(null, all, 'The Record Type Map should not be null');
        }
    }
    
    @isTest static void securityEnabled_test() {
        List<User> userList = new List<User>();
        // Create admin user
        userList.add(aqi_TestDataFactory.createUser(true));
        // Create non admin user
        userList.add(aqi_TestDataFactory.createUser(false));

        System.Test.startTest();
        for (User currentUser : userList) {
            System.runAs(currentUser) {
                System.assertEquals(aqi_SecurityHandlerLng.isAccessible(Case.sObjectType), Case.sObjectType.getDescribe().isAccessible());
                System.assertEquals(aqi_SecurityHandlerLng.isCreateable(Case.sObjectType), Case.sObjectType.getDescribe().isCreateable());
                System.assertEquals(aqi_SecurityHandlerLng.isUpdateable(Case.sObjectType), Case.sObjectType.getDescribe().isUpdateable());
                System.assertEquals(aqi_SecurityHandlerLng.isDeletable(Case.sObjectType), Case.sObjectType.getDescribe().isDeletable());
                System.assertEquals(aqi_SecurityHandlerLng.isAccessible(Case.subject), Case.subject.getDescribe().isAccessible());
                System.assertEquals(aqi_SecurityHandlerLng.isCreateable(Case.subject), Case.subject.getDescribe().isCreateable());
                System.assertEquals(aqi_SecurityHandlerLng.isUpdateable(Case.subject), Case.subject.getDescribe().isUpdateable());
                
                if (Case.sObjectType.getDescribe().isAccessible()) {
                    aqi_SecurityHandlerLng.canAccess(Case.sObjectType);
                } else {
                    try {
                        aqi_SecurityHandlerLng.canAccess(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}
                }
                    
                if (Case.sObjectType.getDescribe().isCreateable()) {
                    aqi_SecurityHandlerLng.canCreate(Case.sObjectType);
                } else {
                    try {
                        aqi_SecurityHandlerLng.canCreate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}
                }
                        
                if (Case.sObjectType.getDescribe().isUpdateable()) {
                    aqi_SecurityHandlerLng.canUpdate(Case.sObjectType);
                } else {
                    try {
                        aqi_SecurityHandlerLng.canUpdate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}
                }
                
                if (Case.sObjectType.getDescribe().isDeletable()) {
                    aqi_SecurityHandlerLng.canDelete(Case.sObjectType);
                } else {
                    try {
                        aqi_SecurityHandlerLng.canDelete(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}
                }

                if (Case.subject.getDescribe().isAccessible()) {
                    aqi_SecurityHandlerLng.canAccess(Case.subject);
                } else {
                    try {
                        aqi_SecurityHandlerLng.canAccess(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}
                }
                
                if (Case.subject.getDescribe().isCreateable()) {
                    aqi_SecurityHandlerLng.canCreate(Case.subject);
                } else {
                    try {
                        aqi_SecurityHandlerLng.canCreate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}
                }
            
                if (Case.subject.getDescribe().isUpdateable()) { 
                    aqi_SecurityHandlerLng.canUpdate(Case.subject);
                } else {
                    try {
                        aqi_SecurityHandlerLng.canUpdate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}
                }
            }
        }

        System.Test.stopTest();
    }

    @isTest static void securityDisabled_test() {
        List<User> userList = new List<User>();
        // Create admin user
        userList.add(aqi_TestDataFactory.createUser(true));
        // Create non admin user
        userList.add(aqi_TestDataFactory.createUser(false));

        System.Test.startTest();
        for (User currentUser : userList) {
            System.runAs(currentUser) {
                System.assertEquals(aqi_SecurityHandlerLng.isAccessible(Case.sObjectType), true);
                System.assertEquals(aqi_SecurityHandlerLng.isCreateable(Case.sObjectType), true);
                System.assertEquals(aqi_SecurityHandlerLng.isUpdateable(Case.sObjectType), true);
                System.assertEquals(aqi_SecurityHandlerLng.isDeletable(Case.sObjectType), true);
                System.assertEquals(aqi_SecurityHandlerLng.isAccessible(Case.subject), true);
                System.assertEquals(aqi_SecurityHandlerLng.isCreateable(Case.subject), true);
                System.assertEquals(aqi_SecurityHandlerLng.isUpdateable(Case.subject), true);

                aqi_SecurityHandlerLng.canAccess(Case.sObjectType);
                aqi_SecurityHandlerLng.canCreate(Case.sObjectType);
                aqi_SecurityHandlerLng.canUpdate(Case.sObjectType);
                aqi_SecurityHandlerLng.canDelete(Case.sObjectType);
                aqi_SecurityHandlerLng.canAccess(Case.subject);
                aqi_SecurityHandlerLng.canCreate(Case.subject);
                aqi_SecurityHandlerLng.canUpdate(Case.subject);
               
                List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                fieldList.add(Case.subject);
                aqi_SecurityHandlerLng.toString(fieldList);
                
                List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
                objectTypeList.add( Case.sObjectType);
                aqi_SecurityHandlerLng.toString(objectTypeList);
            }
        }
        System.Test.stopTest();
    }
}