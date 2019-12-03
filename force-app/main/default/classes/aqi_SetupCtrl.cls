/**
* @author Altimetrik
* @description
* started on January 2018
* Class that resolves logic for custom setting handling
**/
public with sharing class aqi_SetupCtrl {
    public ArticleQuality_index__c aqs {get; set;}
    public Boolean editMode {get; set;}
    public Boolean checkboxEnabled {get;set;}

    public aqi_SetupCtrl() {
        editMode = false;
    }

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
            aqi_SecurityHandlerLng.canCreate(ArticleQuality_index__c.sObjectType);

    		if (aqi_SecurityHandlerLng.isCreateable(ArticleQuality_index__c.sObjectType) && aqi_SecurityHandlerLng.isUpdateable(ArticleQuality_index__c.sObjectType)) {
                upsert aqs;
            }
        
            editMode = false;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
    }


    /*
    * @description
    *   Set the checkbox enabled or disabled
    * @params
    *   N/A
    * @return
    *   pageReference
    */
    public pageReference disableEditCheckboxes(){
        if(aqs.Trigger_Enabled__c){
            checkboxEnabled = true;
        } else {
            checkboxEnabled = false;
            aqs.Prevent_AQI_Edit_on_Archived_Article__c = false;
            aqs.Prevent_AQI_Edit_on_Draft_Article__c = false;
        }
        return null;
    }
}