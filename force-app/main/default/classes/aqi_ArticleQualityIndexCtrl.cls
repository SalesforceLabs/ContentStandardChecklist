/**
* @author Altimetrik
* @description
* started on January 2018
* This class its responsible of return-edit-insert any data of the article
**/
public with sharing class aqi_ArticleQualityIndexCtrl {
    public static String knowledgeObject = aqi_securityHandlerLng.knowledgeObject;
    
    /*
    * @description
    *   Retrieves initial details to load input fields on AQI component
    * @params
    *   Id recordId Id of the Knowkedledge version record home page
    *   String apiNames comma separated list of api names for the input to displau
    * @return
    *   Map with : aqi record  details
    *              aqi indexes values
    */
    @AuraEnabled
    public static aqi_LightningResponse getInitData(String recordId, String apiNames) {
        aqi_LightningResponse response = new aqi_LightningResponse();
        Map<String,Double> indexValues = aqi_Ctrl.getindexApiNameToValue();
        Map<String,String> listApiNamesToLabels = aqi_Ctrl.getAqiObjectApiNameToLabel();
        if (!listApiNamesToLabels.containsKey('Action_Assigned_To__c')) {
            response.state = 'ERROR';
            response.error = System.Label.Follow_up_field_not_retrieved_error;
        } else if (!String.isNotBlank(apiNames)) {
            response.state = 'ERROR';
            response.error = System.Label.List_of_API_names_empty_error;
        } else if (!String.isNotBlank(recordId)) {
            response.state = 'ERROR';
            response.error = System.Label.Article_Id_empty_error;
        } else {
            try {
                Article_Quality__c aqi_result;
                List<indexArticleQualityIndex> indexList = new List<indexArticleQualityIndex>();
                Map<String,Object> result = new Map<String,Object>();
                ArticleQuality_index__c aqs = aqi_SettingsHandler.checkForAppConfiguration();
                Set<String> apiNamesWhiteLilst = indexValues.keySet();
                Set<String> apiList = new Set<String>();
                apiNames = apiNames.replace('"','').replace('[','').replace(']','');
                for (String a : apiNames.split(',')) {
                    if (String.isNotBlank(a) && apiNamesWhiteLilst.contains(a)) {
                        apiList.add(a);
                    }
                }
                
                List<String> uniqueApiNames = new List<String>();
                uniqueApiNames.addAll(apiList);
                String qStringApiNames = String.join(uniqueApiNames, ', ');
                String qStr = ' SELECT Name, Action_Assigned_To__r.Name, Action_Assigned_To__r.Id , Action_Assigned_To__r.FullPhotoUrl, Action_Needed__c, AQ_Score__c, '+
                ' Action_Date__c, Action_Taken__c, Internal_Notes__c, Agent__r.Name, Agent__r.Id, Agent__r.FullPhotoUrl ';
                
                if (String.isNotBlank(qStringApiNames)) {
                    qStr += ', ' + qStringApiNames;
                }
                
                qStr += ' FROM Article_Quality__c WHERE Knowledge_Article_Version_Id__c =\'' + recordId + '\'';
                
                aqi_SecurityHandlerLng.canAccess(Article_Quality__c.sObjectType);
                List<Article_Quality__c> aqiList = Database.query(qStr);
                
                if (aqiList.isEmpty()) {
                    aqi_result = populateInitialAQI(recordId);
                    aqi_SecurityHandlerLng.canAccess(User.sObjectType);
                    List<User> relatedInitiallyAgents = [SELECT FullPhotoUrl, Id, Name FROM User WHERE Id =: aqi_result.Agent__c];

                    if (!relatedInitiallyAgents.isEmpty()) {
                        result.put('relatedInitiallyAgent', relatedInitiallyAgents.get(0));
                    } else {
                        result.put('relatedInitiallyAgent', null);
                    }
                } else {
                    aqi_result = aqiList.get(0);
                }
                
                Map<String,Schema.SObjectField> allFields = Schema.SObjectType.Article_Quality__c.fields.getMap();
                String tmp;
                for (String str : uniqueApiNames) {
                    tmp = str.toLowerCase();
                    if (allFields.containsKey(tmp)) {
                        Schema.DescribeFieldResult dfr = allFields.get(tmp).getDescribe();
                        if (dfr.isCustom() && dfr.getType() == Schema.DisplayType.BOOLEAN) {
                            indexList.add(new indexArticleQualityIndex(dfr.getLabel(),dfr.getName(),true));
                        }
                    }
                }
                result.put('aqi_listApiNamesToLabels', listApiNamesToLabels);
                result.put('aqi_fields', indexList);
                result.put('aqi_record', aqi_result);
                result.put('prefixOrg', aqi_Ctrl.getPackagePrefix());
                
                response.jsonResponse = JSON.serialize(result);
            } catch(Exception e) {
                response = new aqi_LightningResponse(e);
            }
        }
        
        return response;
    }
    
    /*
    * @description
    *   Retrieves initial details to load input fields on AQI component
    * @params
    *   String recordStr JSON string containing new values for the AQI record
    * @return
    *   Map with : aqi record  details
    */
    @AuraEnabled
    public static aqi_LightningResponse upsertAQI(String recordStr) {
        aqi_LightningResponse response = new aqi_LightningResponse();
        Map<String,Double> indexValues = aqi_Ctrl.getindexApiNameToValue();
        Set<String> apiNamesWhiteLilst = indexValues.keySet();
        List<String> tmpList = new List<String>();
        tmpList.addAll(apiNamesWhiteLilst);

        String qStringApiNames = String.join(tmpList,', ');
        if (!String.isNotBlank(recordStr)) {
            return response;
        }

        // Check that user can reference a user Id
        aqi_SecurityHandlerLng.canCreate(User.sObjectType);

        Map<String,Object> result = new Map<String,Object>();
        
        try {
            Article_Quality__c record = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);

            //Set fields not shown in the component to false
            for(String s : tmpList) {
                if(!recordStr.containsIgnoreCase(s) && s != 'Possible_Points__c') {
                    record.put(s, false);
                }
            }

            // Check CRUD permissions
            if (aqi_SecurityHandlerLng.isCreateable(Article_Quality__c.sObjectType) &&
            aqi_SecurityHandlerLng.isUpdateable(Article_Quality__c.sObjectType)) {
                UPSERT record;
            }

            // Load Score field
            aqi_SecurityHandlerLng.canAccess(Article_Quality__c.sObjectType);
            record = Database.query(' SELECT Name, Action_Assigned_To__c , Action_Needed__c, AQ_Score__c, '+
            ' Action_Date__c, Action_Taken__c, Internal_Notes__c, Agent__c , ' + qStringApiNames +
            ' FROM Article_Quality__c '+
            ' WHERE Id =\'' + record.Id + '\'');
            result.put('aqi_record', record);
            response.jsonResponse = JSON.serialize(result);
        } catch(DmlException e) {
            response = new aqi_LightningResponse(e);
            String dmlMessage = e.getDmlMessage(0);
            
            if (e.getDmlType(0) == StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY) {
                // Check if user Id is failing
                if (dmlMessage.contains('005')) {
                    response.error = 'Insufficient access on User object: \'Article contributor\' cannot be assigned. Check that permissions are assigned correctly for the current user, \'View all users\' system permission might be needed.';
                }
            } else {
                response.error = dmlMessage;
            }
        } catch(Exception e) {
            response = new aqi_LightningResponse(e);
            String errorMsg = e.getMessage();
            if (errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                response.error = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            }
        }
        
        return response;
    }
    
    /*
    * @description
    *   Retrieves Article_Quality__c associated to the kav id
    * @params
    *   String kavId
    * @return
    *   Article_Quality__c associated to the kav id
    */
    private static Article_Quality__c populateInitialAQI(String kavId) {
        Article_Quality__c result = null;
        List<Article_Quality__c > aqiList = [
            SELECT Id
            FROM Article_Quality__c
            WHERE Knowledge_Article_Version_Id__c =: kavId
        ];
        
        if (!aqiList.isEmpty()) {
            result = aqiList.get(0);
        } else {
            KnowledgeArticleVersion article = [
                SELECT ArticleNumber, CreatedById, CreatedDate, FirstPublishedDate, Id,
                KnowledgeArticleId, Language, LastModifiedDate, LastPublishedDate,
                PublishStatus, Summary, Title, UrlName, VersionNumber, LastModifiedById
                FROM KnowledgeArticleVersion
                WHERE Id =: kavId
            ];
            
            aqi_SecurityHandlerLng.canCreate(Article_Quality__c.sObjectType);
            result = new Article_Quality__c();
            result = aqi_Ctrl.loadKavDetails(article, result);
        }
        
        return result;
    }
    
    /*
    * @description
    *   Retrieves a Map<String,Object> with some fields of the article compact layout to display on our
    *   lightning component 'aqi_RelatedArticle' and with this avoid some duplicated values on the layout.
    *   For example in the record page of Knowledge we dont need to show the language cause appears on the compact layout
    *   but in other component that contain the article layout data we will need another way to display the language without
    *   add it to the layout.
    * @params
    *   Id of the kav and Map<String,Object> with some fields of the article compact layout
    * @return
    *   Map<String,Object> with the defined fields of the kav with the kavId received
    */
    public static Map<String,Object> getCompactLayoutData(Id kavId, Map<String,Object> result) {
        List<Id> kavIds = new List<Id>();
        kavIds.add(kavId);
        List<KnowledgeArticleVersion> articles = [
            SELECT ArticleNumber, CreatedDate, Id, Language, VersionNumber, PublishStatus 
            FROM KnowledgeArticleVersion WHERE Id IN :kavIds 
        ];
        
        if (!articles.isEmpty()) {
            KnowledgeArticleVersion article = articles.get(0);
            // Find the associated record type
            String queryString = '';
            List<SObject> sObjList = new List<SObject>();
            String recType = 'This article has no record type';
            if (aqi_KnowledgeSearchCtrl.isRecordTypeIdActive) {
                queryString = 'SELECT  Id, RecordTypeId, RecordType.Name FROM ' + knowledgeObject + ' WHERE Id =  \'' + kavId + '\'';
                sObjList = Database.query(queryString);
                if (sObjList != null && !sObjList.isEmpty()) {
                    SObject sObjKnowledge = sObjList.get(0);
                    recType = sObjKnowledge.getSObject('RecordType') != null ? (String) sObjKnowledge.getSObject('RecordType').get('Name') : 'This article has no record type';
                }
            }
            
            result.put('articleVersion', article.VersionNumber);
            result.put('articleRecordType', recType);
            result.put('articleNumber', article.ArticleNumber);
            result.put('articlePublishingStatus', article.PublishStatus);
            Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                if (picklistEntry.getValue() == article.Language) {
                    result.put('articleLanguage', picklistEntry.getLabel());
                }
            }
            
            result.put('errors', System.Label.None_message);
        } else {
            result.put('errors', System.Label.Related_article_not_found_error);
        }
        
        return result;
    }
    
    /*
    * @description
    *   Retrieves a Map<String,Object> with kavId , some necessary fields of the kav and
    *   information about if the article its archived.
    * @params
    *   Id of the aqi object
    * @return
    *   Map<String,Object> with the kav id , some fields of the article compact layout, and information about if the article its archived.
    */
    @AuraEnabled
    public static aqi_LightningResponse loadKAVId(String recordId) {
        aqi_LightningResponse response = new aqi_LightningResponse();
        Map<String,Object> result = new Map<String,Object>();
        String kavId = '';
        try {
            response.state = 'SUCCESS';
            List<Article_Quality__c> aqiList = [SELECT Id, Knowledge_Article_Version_Id__c FROM Article_Quality__c WHERE Id =:recordId];
            if (!aqiList.isEmpty()) {
                kavId =  aqiList.get(0).Knowledge_Article_Version_Id__c;
                result.put('kavId', kavId);
                // Get language version
                result = getCompactLayoutData(kavId, result);
                if (result.get('errors').equals('None')) {
                    Boolean isArchived = false;
                    String query = ' SELECT Id, ArchivedDate, KnowledgeArticleId, Language , VersionNumber ' +
                    ' FROM KnowledgeArticleVersion ' +
                    ' WHERE PublishStatus = \'Archived\' ' +
                    ' AND Id = \'' + kavId + '\' ';
                    aqi_SecurityHandlerLng.canAccess(KnowledgeArticleVersion.sObjectType);
                    
                    List<KnowledgeArticleVersion> actualKavs = Database.query(query);
                    if (!actualKavs.isEmpty()) {
                        isArchived = true;
                    }
                    result.put('isArchived', isArchived);
                } else {
                    response.state = 'ERROR';
                    response.error = result.get('errors').toString();
                }
            } else {
                response.state = 'ERROR';
                response.error = System.Label.Error_getting_id_of_related_article_error;
            }
            response.jsonResponse = JSON.serialize(result);
        } catch(Exception e) {
            response.state = 'ERROR';
        }
        
        return response;
    }
    
    /*
    * @description
    *   Class to wrap some values of the aqi object
    * @params
    *   N/A
    * @return
    *   N/A
    */
    public class indexArticleQualityIndex {
        @AuraEnabled public String fieldLabel {get; set;}
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public Boolean fieldValue {get; set;}
        public indexArticleQualityIndex(String fLabel, String fName, Boolean fValue) {
            fieldLabel = fLabel;
            fieldName = fName;
            fieldValue = fValue;
        }
    }
}