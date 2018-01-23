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
    *   Return a map with the weight of each api name configured previously
    * @params
    *   N/A
    * @return
    *   Map<String, Double>
    */
    public static Map<String,Double>  getindexApiNameToValue(){
        ArticleQuality_index__c aqs = aqi_SettingsHandler.getSettings();
        Map<String, Schema.SObjectField> allFields = Schema.SObjectType.ArticleQuality_index__c.fields.getMap();

        Map<String,Double> result = new Map<String,Double>();
        Double idx_val;
        String idx_api_name;
        for(String str : allFields.keySet()){
            Schema.DescribeFieldResult dfr = allFields.get(str).getDescribe();
            idx_api_name = dfr.getName();
            if (dfr.getType() ==Schema.DisplayType.DOUBLE){
                idx_val =  Double.valueOf(aqs.get(idx_api_name));
                //system.debug('\n'+str+':'+idx_api_name+' - '+dfr.getType()+' value '+idx_val);
                result.put(idx_api_name,idx_val);
            }
        }
        return result;
    }


}