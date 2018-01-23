public with sharing class aqi_SecurityHandler {

    /**
     *  Constants
     **/
     public static final String  ERROR_OBJECT_NOT_ACCESSIBLE = 'You do not have access to the following objects: {0}. Please contact your Salesforce Administrator for assistance.';
     public static final String  ERROR_OBJECT_NOT_UPDATEABLE = 'You cannot update the following objects: {0}. Please contact your Salesforce Administrator for assistance.';
     public static final String  ERROR_OBJECT_NOT_CREATEABLE = 'You cannot create the following objects: {0}. Please contact your Salesforce Administrator for assistance.';
     public static final String  ERROR_OBJECT_NOT_DELETABLE = 'You cannot delete the following objects: {0}. Please contact your Salesforce Administrator for assistance.';
     public static final String  ERROR_FIELD_NOT_ACCESSIBLE = 'You do not have access to the following fields: {0} Please contact your Salesforce Administrator for assistance.';
     public static final String  ERROR_FIELD_NOT_UPDATEABLE = 'You cannot update the following fields: {0} Please contact your Salesforce Administrator for assistance.';
     public static final String  ERROR_FIELD_NOT_CREATEABLE = 'You cannot create the following fields: {0} Please contact your Salesforce Administrator for assistance.';

     //************************************************************************
     // Properties & data members
     public static Boolean securityEnabled { get; set; }
     public static Boolean isPrivateSharingEnabled { get; set; }

     public static String knowledgeObject {
         get {
             if (knowledgeObject == null) {
                 if (getKAVPermissions()) {
                     Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                     Set<String> keySet = gd.keySet();
                     for (String key : keySet) {
                         Schema.SObjectType objectType = gd.get(key);
                         if (key.endsWith('kav')) {
                             knowledgeObject = objectType.getDescribe().getName();
                         }
                     }
                 }
             }
             return knowledgeObject;
         }
         private set;
     }

     //@Description: (get/set) List of Record Types
     public static List<RecordType> allRecordTypes {
         get {
             if (allRecordTypes == null) {
                 allRecordTypes = [SELECT DeveloperName, Id, Name FROM RecordType WHERE SobjectType =: knowledgeObject];
             }
             return allRecordTypes;
         }
         private set;
     }

     static {
         securityEnabled = true;
         isPrivateSharingEnabled = true;
     }
    //************************************************************************
    // Methods

    /*
    * @description
    *   Constructor
    * @params
    *   N/A
    * @return
    *   N/A
    */
    public aqi_SecurityHandler() {

    }

    /*
    * @description
    *   Return a boolean to know if an Object Type List is accesible
    * @params
    *   List of objectType
    * @return
    *   Boolean
    */
    public static Boolean isAccessible(Schema.SObjectType[] objectTypeList) {
        if (securityEnabled) {
            for (Schema.SObjectType objectType : objectTypeList) {
                if (!objectType.getDescribe().isAccessible()) {
                    return false;
                }
            }
        }
        return true;
    }

    /*
    * @description
    *   Return a boolean to know if an Object Type List is updateable
    * @params
    *   List of objectType
    * @return
    *   Boolean
    */
    public static Boolean isUpdateable(Schema.SObjectType[] objectTypeList) {
        if (securityEnabled) {
            for (Schema.SObjectType objectType : objectTypeList) {
                if (!objectType.getDescribe().isUpdateable()) {
                    return false;
                }
            }
        }
        return true;
    }

    /*
    * @description
    *   Return a boolean to know if an Object Type List is createable
    * @params
    *   List of objectType
    * @return
    *   Boolean
    */
    public static Boolean isCreateable(Schema.SObjectType[] objectTypeList) {
        if (securityEnabled) {
            for (Schema.SObjectType objectType : objectTypeList) {
                if (!objectType.getDescribe().isCreateable()) {
                    return false;
                }
            }
        }
        return true;
    }

    /*
    * @description
    *   Return a boolean to know if an Object Type List is deletable
    * @params
    *   List of objectType
    * @return
    *   Boolean
    */
    public static Boolean isDeletable(Schema.SObjectType[] objectTypeList) {
        if (securityEnabled) {
            for (Schema.SObjectType objectType : objectTypeList) {
                if (!objectType.getDescribe().isDeletable()) {
                    return false;
                }
            }
        }
        return true;
    }

    /*
    * @description
    *   Return a boolean to know if an Object Field List is accessible
    * @params
    *   List of field
    * @return
    *   Boolean
    */
    public static Boolean isAccessible(Schema.SObjectField[] fieldList) {
        if (securityEnabled) {
            for (Schema.SObjectField field : fieldList) {
                if (!field.getDescribe().isAccessible()) {
                    return false;
                }
            }
        }
        return true;
    }

    /*
    * @description
    *   Return a boolean to know if an Object Field List is updateable
    * @params
    *   List of field
    * @return
    *   Boolean
    */
    public static Boolean isUpdateable(Schema.SObjectField[] fieldList) {
        if (securityEnabled) {
            for (Schema.SObjectField field : fieldList) {
                if (!field.getDescribe().isUpdateable()) {
                    return false;
                }
            }
        }
        return true;
    }

    /*
    * @description
    *   Return a boolean to know if an Object Field List is createable
    * @params
    *   List of field
    * @return
    *   Boolean
    */
    public static Boolean isCreateable(Schema.SObjectField[] fieldList) {
        if (securityEnabled) {
            for (Schema.SObjectField field : fieldList) {
                if (!field.getDescribe().isCreateable()) {
                    return false;
                }
            }
        }
        return true;
    }

    /*
    * @description
    *   Return a boolean to know if an Object Type is accessible
    * @params
    *   Object Type
    * @return
    *   Boolean
    */
    public static Boolean isAccessible(Schema.SObjectType objectType) {
        return isAccessible(new Schema.SObjectType[] {objectType});
    }

    /*
    * @description
    *   Return a boolean to know if an Object Type is updateable
    * @params
    *   Object Type
    * @return
    *   Boolean
    */
    public static Boolean isUpdateable(Schema.SObjectType objectType) {
        return isUpdateable(new Schema.SObjectType[] {objectType});
    }

    /*
    * @description
    *   Return a boolean to know if an Object Type is createable
    * @params
    *   Object Type
    * @return
    *   Boolean
    */
    public static Boolean isCreateable(Schema.SObjectType objectType) {
        return isCreateable(new Schema.SObjectType[] {objectType});
    }

    /*
    * @description
    *   Return a boolean to know if an Object Type is deletable
    * @params
    *   Object Type
    * @return
    *   Boolean
    */
    public static Boolean isDeletable(Schema.SObjectType objectType) {
        return isDeletable(new Schema.SObjectType[] {objectType});
    }

    /*
    * @description
    *   Return a boolean to know if an Object Field is accessible
    * @params
    *   List of fieldList
    * @return
    *   Boolean
    */
    public static Boolean isAccessible(Schema.SObjectField field) {
        return isAccessible(new Schema.SObjectField[] {field});
    }

    /*
    * @description
    *   Return a boolean to know if an Object Field is updateable
    * @params
    *   Object Field
    * @return
    *   Boolean
    */
    public static Boolean isUpdateable(Schema.SObjectField field) {
        return isUpdateable(new Schema.SObjectField[] {field});
    }

    /*
    * @description
    *   Return a boolean to know if an Object Field is createable
    * @params
    *   Object Field
    * @return
    *   Boolean
    */
    public static Boolean isCreateable(Schema.SObjectField field) {
        return isCreateable(new Schema.SObjectField[] {field});
    }

    /*
    * @description
    *   Throw an error if cant access to the Object Type List
    * @params
    *   List of type
    * @return
    *   N/A
    */
    public static void canAccess(Schema.SObjectType[] objectTypeList) {
        if (!isAccessible(objectTypeList)) {
            throw new SecurityException(formatReplace(ERROR_OBJECT_NOT_ACCESSIBLE, new String[] {toString(objectTypeList)}));
        }
    }

    /*
    * @description
    *   Throw an error if cant update to the Object Type List
    * @params
    *   List of type
    * @return
    *   N/A
    */
    public static void canUpdate(Schema.SObjectType[] objectTypeList) {
        if (!isUpdateable(objectTypeList)) {
            throw new SecurityException(formatReplace(ERROR_OBJECT_NOT_UPDATEABLE, new String[]{toString(objectTypeList)}));
        }
    }

    /*
    * @description
    *   Throw an error if cant create to the Object Type List
    * @params
    *   List of type
    * @return
    *   N/A
    */
    public static void canCreate(Schema.SObjectType[] objectTypeList) {
        if (!isCreateable(objectTypeList)) {
            throw new SecurityException(formatReplace( ERROR_OBJECT_NOT_CREATEABLE, new String[] {toString(objectTypeList)}));
        }
    }

    /*
    * @description
    *   Throw an error if cant delete to the Object Type List
    * @params
    *   List of type
    * @return
    *   N/A
    */
    public static void canDelete(Schema.SObjectType[] objectTypeList) {
        if (!isDeletable(objectTypeList)) {
            throw new SecurityException(formatReplace( ERROR_OBJECT_NOT_DELETABLE, new String[] {toString(objectTypeList)}));
        }
    }

    /*
    * @description
    *   Throw an error if cant access to the Object field List
    * @params
    *   List of field
    * @return
    *   N/A
    */
    public static void canAccess(Schema.SObjectField[] fieldList) {
        if (!isAccessible(fieldList)) {
            throw new SecurityException(formatReplace( ERROR_FIELD_NOT_ACCESSIBLE, new String[] {toString(fieldList)}));
        }
    }

    /*
    * @description
    *   Throw an error if cant update to the Object field List
    * @params
    *   List of field
    * @return
    *   N/A
    */
    public static void canUpdate(Schema.SObjectField[] fieldList) {
        if (!isUpdateable(fieldList)) {
            throw new SecurityException(formatReplace( ERROR_FIELD_NOT_UPDATEABLE, new String[] {toString(fieldList)}));
        }
    }

    /*
    * @description
    *   Throw an error if cant create to the Object field List
    * @params
    *   List of field
    * @return
    *   N/A
    */
    public static void canCreate(Schema.SObjectField[] fieldList) {
        if (!isCreateable(fieldList)) {
            throw new SecurityException(formatReplace( ERROR_FIELD_NOT_CREATEABLE, new String[] {toString(fieldList)}));
        }
    }

    /*
    * @description
    *   Call to the method that throw an error if cant access to the Object Type
    * @params
    *   Object Type
    * @return
    *   N/A
    */
    public static void canAccess(Schema.SObjectType objectType) {
        canAccess(new Schema.SObjectType[] {objectType});
    }

    /*
    * @description
    *   Call to the method that throw an error if cant update to the Object Type
    * @params
    *   Object Type
    * @return
    *   N/A
    */
    public static void canUpdate(Schema.SObjectType objectType) {
        canUpdate(new Schema.SObjectType[] {objectType});
    }

    /*
    * @description
    *   Call to the method that throw an error if cant create to the Object Type
    * @params
    *   Object Type
    * @return
    *   N/A
    */
    public static void canCreate(Schema.SObjectType objectType) {
        canCreate(new Schema.SObjectType[] {objectType});
    }

    /*
    * @description
    *   Call to the method that throw an error if cant delete to the Object Type
    * @params
    *   Object Type
    * @return
    *   N/A
    */
    public static void canDelete(Schema.SObjectType objectType) {
        canDelete(new Schema.SObjectType[] {objectType});
    }

    /*
    * @description
    *   Call to the method that throw an error if cant access to the Object Field
    * @params
    *   Object Field
    * @return
    *   N/A
    */
    public static void canAccess(Schema.SObjectField field) {
        canAccess(new Schema.SObjectField[] {field});
    }

    /*
    * @description
    *   Call to the method that throw an error if cant update to the Object Field
    * @params
    *   Object Field
    * @return
    *   N/A
    */
    public static void canUpdate(Schema.SObjectField field) {
        canUpdate(new Schema.SObjectField[] {field});
    }

    /*
    * @description
    *   Call to the method that throw an error if cant create to the Object Field
    * @params
    *   Object Field
    * @return
    *   N/A
    */
    public static void canCreate(Schema.SObjectField field) {
        canCreate(new Schema.SObjectField[] {field});
    }

    /*
    * @description
    *   Method that convert object type list to list of labels
    * @params
    *   Object Type List
    * @return
    *   String
    */
    public static String toString(Schema.SObjectType[] objectTypeList) {
        String result = '';
        if (!objectTypeList.isEmpty()) {
            result = objectTypeList[0].getDescribe().getLabel();
            for (Integer i = 1; i < objectTypeList.size(); ++i) {
                result += ', ' + objectTypeList[i].getDescribe().getLabel();
            }
        }
        return result;
    }

    /*
    * @description
    *   Method that convert object field list to list of labels
    * @params
    *   Object Field List
    * @return
    *   String
    */
    public static String toString(Schema.SObjectField[] fieldList) {
        String result = '';
        if (!fieldList.isEmpty()) {
            result = fieldList[0].getDescribe().getLabel();
            for (Integer i = 1; i < fieldList.size(); ++i) {
                result += ', ' + fieldList[i].getDescribe().getLabel();
            }
        }
        return result;
    }

    /*
    * @description
    *   Maps the content of a list to another list using a Mapper object.
    * @params
    *  The output list where the result will be added.
    * @return
    *   String
    */
    public static String formatReplace(String value, List<String> lstStr){

        String res = value;

        for( Integer i=0; i<lstStr.size(); i++ ){
            if( lstStr[i] != null && lstStr[i] != '' )
                res = res.replaceAll('\\{'+i+'\\}', lstStr[i]);
        }
        return res;
    }

    /*
    * @description
    *   Return a String with the allowed record types separated by comma.
    * @params
    *   N/A
    * @return
    *   String
    */
    public static String getAllowedRecordTypes() {
        String res = '';

        for (RecordType rt : allRecordTypes) {
            res += '\'' + rt.DeveloperName + '\',';
        }

        if (String.isEmpty(res))
            res = null;
        else
            res = res.substring(0, res.length()-1);

        return res;
    }

    /*
    * @description
    *   Return a Map of the Id -> Record Type allowed.
    * @params
    *   N/A
    * @return
    *   Map<Id,String>
    */
    public static Map<Id,String> getAllowedRecordTypesMap() {
        Map<Id,String> res = new Map<Id,String>();

        for (RecordType rt : allRecordTypes) {
            res.put(rt.Id, rt.Name);
        }

        if (res.size() == 0)
            res = null;

        return res;
    }

    /*
    * @description
    *   Return a Map of the Record Type -> Id allowed.
    * @params
    *   N/A
    * @return
    *   Map<Id,String>
    */
    public static Map<String,Id> getAllowedRecordTypeNameToIdMap() {
        Map<String,Id> res = new Map<String,Id>();

        for (RecordType rt : allRecordTypes) {
            res.put(rt.Name, rt.Id);
        }

        if (res.size() == 0)
            res = null;

        return res;
    }
 

    public class SecurityException extends Exception {}

    /*
    * @description
    *   Return a boolean to know if we had kav permissions
    * @params
    *   N/A
    * @return
    *   Boolean
    */
    public static Boolean getKAVPermissions() {
        Boolean result = false;
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();

        for (String s : gd.keySet()) {
            if (s.contains('__kav'))
                result = gd.get(s).getDescribe().isAccessible();
        }
        return result ;
    }
}