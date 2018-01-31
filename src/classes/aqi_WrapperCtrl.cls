/**
 * @author Altimetrik
 * @description
 *  started on MM/DD/YYYY
 *  REPLACE_BY_CLASS_LOGIC_RESPONSABILITIES
 **/
public with sharing class aqi_WrapperCtrl {
    // Constants

    //************************************************************************
    // Properties & data members



    //************************************************************************
    // Methods

    public aqi_WrapperCtrl() {

    }

    /*
    * @description
    *   retrieves initial details to load input fields on AQI component
    * @params
    *   Id recordId Id of the Knowkedledge version record home page
    *   String apiNames comma separated list of api names for the input to displau
    * @return
    *   Map with : aqi record  details
    *              aqi indexes values
    */
    @AuraEnabled
    public static aqi_LightningResponse getInitData(String recordId, String apiNames){

	    aqi_LightningResponse response = new aqi_LightningResponse();
        Map<String,Double>  indexValues = aqi_Ctrl.getindexApiNameToValue();
        system.debug(recordId);
        system.debug(apiNames);


        if (!String.isNotBlank(apiNames)){
                response.state = 'ERROR';
                response.error = 'List of API names can not be empty';
        }else
            if (!String.isNotBlank(recordId)){
                response.state = 'ERROR';
                response.error = 'Article Id  can not be empty';
            }else{
                try{
                    Article_Quality__c aqi_result;
                    List<indexWrapper> indexList = new List<indexWrapper>();
                    Boolean appIsConfigured = aqi_SettingsHandler.isAppConfigured();
                    Map<String,  Object> result = new Map<String,  Object>();

                    if (appIsConfigured){

                         ArticleQuality_index__c aqs = aqi_SettingsHandler.getSettings();

                        system.debug('into try of getInitData');
                        set<String> apiNamesWhiteLilst = indexValues.keySet();
                        system.debug(apiNamesWhiteLilst);

                        set<String> apiList  = new set<String>();
                        apiNames = apiNames.replace('"','').replace('[','').replace(']','');
                        for (String a : apiNames.split(',')){
                            if (String.isNotBlank(a) && apiNamesWhiteLilst.contains(a)){
                                apiList.add(a);
                                system.debug(a);
                            }
                        }

                        //@todo : filter field list according to permissions
                        List<String> uniqueApiNames = new List<String>();
                        uniqueApiNames.addAll(apiList);

                        String qStringApiNames = String.join(uniqueApiNames,', ');

                        system.debug(qStringApiNames);


                        String qStr =   ' SELECT Name, Action_Assigned_To__r.Name, Action_Assigned_To__r.Id , Action_Assigned_To__r.FullPhotoUrl, Action_Needed__c, AQ_Score__c, '+
                                        '      Action_Date__c, Action_Taken__c, Internal_Notes__c ';

                        if (String.isNotBlank(qStringApiNames))
                                qStr +=  ', '+qStringApiNames;

                        qStr += ' FROM Article_Quality__c '+
                                ' WHERE '+
                                ' Knowledge_Article_Version_Id__c =\''+recordId+'\'';

                        system.debug(qStr);

                        List<Article_Quality__c > l = Database.query(   qStr );
                        if (l.isEmpty()){
                            aqi_result =populateInitialAQI(recordId);
                        }else{
                            aqi_result = l.get(0);
                        }

                        Map<String, Schema.SObjectField> allFields = Schema.SObjectType.Article_Quality__c.fields.getMap();
                        String tmp;
                        for(String str : uniqueApiNames){
                            tmp = str.toLowerCase();
                            if (allFields.containsKey(tmp)){
                                Schema.DescribeFieldResult dfr = allFields.get(tmp).getDescribe();
                                if (dfr.isCustom() && dfr.getType() ==Schema.DisplayType.BOOLEAN){
                                    system.debug('\n'+tmp+':'+dfr.getType());
                                    indexList.add(new indexWrapper(dfr.getLabel(),dfr.getName(),true));
                                }
                            }else{
                                system.debug('\n NOT '+tmp);
                            }
                        }
                    }

                    result.put('aqi_appIsConfigured',appIsConfigured);
                    result.put('aqi_fields',indexList);
                    result.put('aqi_record',aqi_result);
                    response.jsonResponse = JSON.serialize(result);

                }catch(Exception e){
                    response = new aqi_LightningResponse(e);
                }
            }
		return response;
    }

    /*
    * @description
    *   retrieves initial details to load input fields on AQI component
    * @params
    *   String recordStr JSON string containing new values for the AQI record
    * @return
    *   Map with : aqi record  details
    */
    @AuraEnabled
    public static aqi_LightningResponse upsertAQI(String recordStr){

        aqi_LightningResponse response = new aqi_LightningResponse();
        Map<String,  Object> result = new Map<String,  Object>();

        Map<String,Double>  indexValues = aqi_Ctrl.getindexApiNameToValue();
        Set<String> apiNamesWhiteLilst = indexValues.keySet();
        List<String> tmpList  = new List<String>();
        tmpList.addAll(apiNamesWhiteLilst);
        String qStringApiNames = String.join(tmpList,', ');

        system.debug(recordStr);
        if (!String.isNotBlank(recordStr)) return response;
        try{
            Article_Quality__c record = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
            upsert record;
            //load Score field
            record = Database.query(   ' SELECT Name, Action_Assigned_To__c , Action_Needed__c, AQ_Score__c, '+
                                        '           Action_Date__c, Action_Taken__c, Internal_Notes__c, '+
                                        qStringApiNames +
                                        ' FROM Article_Quality__c '+
                                        ' WHERE '+
                                        ' Id =\''+record.Id+'\'');
            result.put('aqi_record',record);
            system.debug('\n======== UPDATE AQI =======');
            system.debug(record);
            response.jsonResponse = JSON.serialize(result);
        }catch(Exception e){
            response = new aqi_LightningResponse(e);
        }
        return response;

    }


    private static Article_Quality__c populateInitialAQI(String kavId){
        Article_Quality__c result = null;
        List<Article_Quality__c > l = [Select Id
                                       from Article_Quality__c
                                       where Knowledge_Article_Version_Id__c =:kavId];
        if (!l.isEmpty()){
            result = l.get(0);

        }else{
            result = new Article_Quality__c();
            KnowledgeArticleVersion article = [ SELECT ArticleNumber,CreatedById,CreatedDate,FirstPublishedDate,Id,
                                                KnowledgeArticleId,Language,LastModifiedDate,LastPublishedDate,
                                                PublishStatus,Summary,Title,UrlName,VersionNumber,LastModifiedById
                                         FROM KnowledgeArticleVersion
                                         WHERE
                                                Id =:kavId
            ];
            result = aqi_Ctrl.loadKavDetails( article ,  result);
            //insert result;
        }
        return result;
    }



	@AuraEnabled
    public static String loadKAVId(String recordId){
        String result = null;
        List<Article_Quality__c > l = [Select Id, Knowledge_Article_Version_Id__c  from Article_Quality__c  where id=:recordId];
        if (!l.isEmpty()){
            result = l.get(0).Knowledge_Article_Version_Id__c;

        }

        return result;
    }

  public class indexWrapper{
        @AuraEnabled public  String fieldLabel{get;set;}
        @AuraEnabled public  String fieldName{get;set;}
        @AuraEnabled public  Boolean fieldValue{get;set;}

        public indexWrapper(String fLabel, String fName, Boolean fValue){
            fieldLabel = fLabel;
            fieldName = fName;
            fieldValue = fValue;
        }
    }
}
