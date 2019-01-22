/**
* @author Altimetrik
* @description
* started on January 2018
* This class its responsible of resolves logic for custom setting handling
**/
public with sharing class aqi_SetupCtrl {
    // Constants

    //************************************************************************
    // Properties & data members
    public ArticleQuality_index__c aqs {get;set;}
    public Boolean editMode {get;set;}
    //************************************************************************
    // Constructor

    public aqi_SetupCtrl() {
        editMode = false;
    }

    //Methods

    public pageReference checkForAppConfiguration() {
        aqs = aqi_SettingsHandler.checkForAppConfiguration();
        return null;
    }
    /*
    * @description
    *   Set the edit mode to true
    * @params
    *   N/A
    * @return
    *   pageReference
    */
    public pageReference edit() {
        editMode = true;
        return null;
    }

    /*
    * @description
    *   Set the edit mode to false
    * @params
    *   N/A
    * @return
    *   pageReference
    */
    public pageReference cancel() {
        editMode = false;
        aqs = aqi_SettingsHandler.cleanCS();
        return null;
    }

    /*
    * @description
    *   Set the edit mode to false
    * @params
    *   N/A
    * @return
    *   pageReference
    */
    public pageReference save() {
        try {
            aqi_SecurityHandler.canCreate(ArticleQuality_index__c.sObjectType);

    		if (aqi_SecurityHandler.isCreateable(ArticleQuality_index__c.sObjectType) && aqi_SecurityHandler.isUpdateable(ArticleQuality_index__c.sObjectType)) {
                upsert aqs;
            }
            editMode = false;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                                ApexPages.Severity.ERROR,
                                e.getMessage()
                           ));
        }
        return null;
    }

    /*
    * @description
    *   Return api name of Knowledge object
    * @params
    *   N/A
    * @return
    *   String
    */
    public static String getKnowledgeApiName() {
        String result='';
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();

        List<String> apiNames = new List<String>();
        apiNames.addAll(gd.keySet());

        while ( ! apiNames.isEmpty() && !String.isNotBlank(result)) {
            if (apiNames.get(0).contains('__kav')) {
                result = apiNames.get(0);
            }
            apiNames.remove(0);
        }
        return result;
    }
}
