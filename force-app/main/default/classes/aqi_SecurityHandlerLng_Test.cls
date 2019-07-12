/**
* @author Altimetrik
* @description
*	started on January 2018
*   This class test the aqi_LightningResponse Class
**/
@isTest
private class aqi_SecurityHandlerLng_Test {
    /*
    Description: Check if exist any record type - the returned map of record types in case that exist shouldn't be null
    */
    @isTest static void test_allRecordTypes() {
        if (aqi_KnowledgeSearchCtrl.checkForSchemaFieldActive('recordtypeid')) {
            System.Test.startTest();
            List<RecordType> allRecord = aqi_SecurityHandlerLng.allRecordTypes;
            System.Test.stopTest();

            system.assertNotEquals(null, allRecord, 'The Record Type Map should not be null');
        }
    }
    
    /*
    Description: Check if exist any recordType - one of those must be returned
    */
    @isTest static void test_getAllowedRecordTypesMap() {
        if (aqi_KnowledgeSearchCtrl.checkForSchemaFieldActive('recordtypeid')) {
            System.Test.startTest();
            Map<Id,String> all = aqi_SecurityHandlerLng.getAllowedRecordTypesMap() ;
            System.Test.stopTest();

            system.assertNotEquals(null, all, 'The Record Type Map should not be null');
        }
    }
    
    /*
    Description: Check if exist any record type - if exist then check that the map shouldn't be null
    */
    @isTest static void test_getAllowedRecordTypeNameToIdMap() {
        if (aqi_KnowledgeSearchCtrl.checkForSchemaFieldActive('recordtypeid')) {
            System.Test.startTest();
            Map<String,Id> all = aqi_SecurityHandlerLng.getAllowedRecordTypeNameToIdMap();
            System.Test.stopTest();

            system.assertNotEquals(null,all,'The Record Type Map should not be null');
        }
    }
    
    /*
    Description: Check for security accessibility on case object
    */
    @isTest static void testSecurityEnabled() {
        System.Test.startTest();
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' LIMIT 2];
        Map<Id,String> profileMap = new Map<Id,String>();
        for (Profile p : profileList) {
            profileMap.put( p.id, p.Name);
        }

        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];
        
        if (profileMap.containsKey( UserInfo.getProfileId()) && profileMap.get( UserInfo.getProfileId()) == 'System Administrator') {
            for (Profile p : profileList) {
                u[0].profileId = p.Id;
                UPDATE u;
                
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
                                
    /*
    Description: Check for the access to the case object
    */
    @isTest static void testSecurityDisabled() {
        System.Test.startTest();
        aqi_SecurityHandlerLng.securityEnabled = false;
        Profile[] profileList = [SELECT Id, Name FROM Profile where Name = 'System Administrator' OR Name = 'Standar User' LIMIT 2];
        Map<Id,String> profileMap = new Map<Id,String>();
        for (Profile p : profileList) {
            profileMap.put(p.id, p.Name);
        }

        List<User> u = [SELECT id, profileId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        if (profileMap.containsKey( UserInfo.getProfileId()) && profileMap.get( UserInfo.getProfileId()) == 'System Administrator') {
            for (Profile p : profileList) {
                u[0].profileId = p.id;
                UPDATE u;
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