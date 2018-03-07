@isTest
private class aqi_SecurityHandler_Test {


 /**
    * Security Manager Test Methods
    */
    public static testMethod void test_allRecordTypes(){
        List<RecordType> allRecord = aqi_SecurityHandler.allRecordTypes;
        if(aqi_KnowledgeSearchCtrl.checkForSchemaFieldActive('recordtypeid')){
        	system.assertNotEquals(null,allRecord,'The Record Type Map should not be null');
        }
    }

    public static testMethod void test_getAllowedRecordTypesMap(){
        Map<Id,String> all = aqi_SecurityHandler.getAllowedRecordTypesMap() ;
        if(aqi_KnowledgeSearchCtrl.checkForSchemaFieldActive('recordtypeid')){
        	system.assertNotEquals(null,all,'The Record Type Map should not be null');
        }
    }

    public static testMethod void test_getAllowedRecordTypeNameToIdMap(){
        Map<String,Id> all = aqi_SecurityHandler.getAllowedRecordTypeNameToIdMap() ;
        if(aqi_KnowledgeSearchCtrl.checkForSchemaFieldActive('recordtypeid')){
        	system.assertNotEquals(null,all,'The Record Type Map should not be null');
        }
    }

    public static testMethod void testSecurityEnabled() {
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

        Map<Id,String> profileMap = new Map<Id,String>();

        for( Profile p : profileList ){
            profileMap.put( p.id, p.Name );
        }
        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

        if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ){

            for (Profile p : profileList) {

                u[0].profileId = p.id;
                update u;
                System.assertEquals(aqi_SecurityHandler.isAccessible(Case.sObjectType), Case.sObjectType.getDescribe().isAccessible());
                System.assertEquals(aqi_SecurityHandler.isCreateable(Case.sObjectType), Case.sObjectType.getDescribe().isCreateable());
                System.assertEquals(aqi_SecurityHandler.isUpdateable(Case.sObjectType), Case.sObjectType.getDescribe().isUpdateable());
                System.assertEquals(aqi_SecurityHandler.isDeletable(Case.sObjectType), Case.sObjectType.getDescribe().isDeletable());

                System.assertEquals(aqi_SecurityHandler.isAccessible(Case.subject), Case.subject.getDescribe().isAccessible());
                System.assertEquals(aqi_SecurityHandler.isCreateable(Case.subject), Case.subject.getDescribe().isCreateable());
                System.assertEquals(aqi_SecurityHandler.isUpdateable(Case.subject), Case.subject.getDescribe().isUpdateable());

                if (Case.sObjectType.getDescribe().isAccessible())
                    aqi_SecurityHandler.canAccess(Case.sObjectType);
                else
                    try {
                        aqi_SecurityHandler.canAccess(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isCreateable())
                    aqi_SecurityHandler.canCreate(Case.sObjectType);
                else
                    try {
                        aqi_SecurityHandler.canCreate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isUpdateable())
                    aqi_SecurityHandler.canUpdate(Case.sObjectType);
                else
                    try {
                        aqi_SecurityHandler.canUpdate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isDeletable())
                    aqi_SecurityHandler.canDelete(Case.sObjectType);
                else
                    try {
                        aqi_SecurityHandler.canDelete(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isAccessible())
                    aqi_SecurityHandler.canAccess(Case.subject);
                else
                    try {
                        aqi_SecurityHandler.canAccess(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isCreateable())
                    aqi_SecurityHandler.canCreate(Case.subject);
                else
                    try {
                        aqi_SecurityHandler.canCreate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isUpdateable())
                    aqi_SecurityHandler.canUpdate(Case.subject);
                else
                    try {
                        aqi_SecurityHandler.canUpdate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}
            }
        }

    }

    public static testMethod void testSecurityDisabled() {
        aqi_SecurityHandler.securityEnabled = false;
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

        Map<Id,String> profileMap = new Map<Id,String>();

        for( Profile p : profileList ){
            profileMap.put( p.id, p.Name );
        }
        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

        if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ){

            for (Profile p : profileList) {
                u[0].profileId = p.id;
                update u;
                System.assertEquals(aqi_SecurityHandler.isAccessible(Case.sObjectType), true);
                System.assertEquals(aqi_SecurityHandler.isCreateable(Case.sObjectType), true);
                System.assertEquals(aqi_SecurityHandler.isUpdateable(Case.sObjectType), true);
                System.assertEquals(aqi_SecurityHandler.isDeletable(Case.sObjectType), true);

                System.assertEquals(aqi_SecurityHandler.isAccessible(Case.subject), true);
                System.assertEquals(aqi_SecurityHandler.isCreateable(Case.subject), true);
                System.assertEquals(aqi_SecurityHandler.isUpdateable(Case.subject), true);

                aqi_SecurityHandler.canAccess(Case.sObjectType);
                aqi_SecurityHandler.canCreate(Case.sObjectType);
                aqi_SecurityHandler.canUpdate(Case.sObjectType);
                aqi_SecurityHandler.canDelete(Case.sObjectType);

                aqi_SecurityHandler.canAccess(Case.subject);
                aqi_SecurityHandler.canCreate(Case.subject);
                aqi_SecurityHandler.canUpdate(Case.subject);

                List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                fieldList.add( Case.subject );
                aqi_SecurityHandler.toString(fieldList);

                List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
                objectTypeList.add( Case.sObjectType );
                aqi_SecurityHandler.toString(objectTypeList);
            }
        }

    }


}
