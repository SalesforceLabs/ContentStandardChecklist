/**
 * @author Altimetrik
 * @description
 *  started on MM/DD/YYYY
 *  REPLACE_BY_CLASS_LOGIC_RESPONSABILITIES
 **/
public with sharing class aqi_SetupCtrl {
    // Constants

    //************************************************************************
    // Properties & data members
    public ArticleQuality_index__c aqs {get;set;}
    public Boolean editMode {get;set;}
    //************************************************************************
    // Methods

    public aqi_SetupCtrl() {
        aqs = aqi_SettingsHandler.getSettings();
        if (aqs == null){
            aqs  = aqi_SettingsHandler.resolveSettings();
            editMode = true;
        }else{
            editMode = false;
        }
    }

    /*
    * @description
    *   Set the edit mode to true
    * @params
    *   N/A
    * @return
    *   pageReference
    */
    public pageReference edit(){
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
    public pageReference cancel(){
        editMode = false;
        aqs = aqi_SettingsHandler.getSettings();
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
    public pageReference save(){
        try{
            aqi_SecurityHandler.canCreate(ArticleQuality_index__c.sObjectType);
            upsert aqs;
            editMode = false;
        }catch(Exception e){
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
    public static String getKnowledgeApiName(){
        String result='';
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();

        List<String> apiNames = new List<String>();
        apiNames.addAll(gd.keySet());

        while ( ! apiNames.isEmpty() && !String.isNotBlank(result)){
            if (apiNames.get(0).contains('__kav')){
                result = apiNames.get(0);
            }
            apiNames.remove(0);
        }
        return result;
    }
}