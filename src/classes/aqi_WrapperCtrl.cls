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
        
        try{
			system.debug('into try of getInitData');
             Map<String,  Object> result = new Map<String,  Object>();
            if (String.isNotBlank(apiNames)){
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
                List<indexWrapper> indexList = new List<indexWrapper>();
                List<String> uniqueApiNames = new List<String>();
                uniqueApiNames.addAll(apiList);
        
                String qStringApiNames = String.join(uniqueApiNames,', ');
            
system.debug(qStringApiNames);

                Article_Quality__c aqi_result;
                String qStr =   ' SELECT Name, Action_Assigned_To__c , Action_Needed__c, AQ_Score__c, '+
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
                
                for(String k : allFields.keySet())
                            system.debug('\n k '+k);
                
                result.put('aqi_fields',indexList);
                result.put('aqi_record',aqi_result);
                

            }


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
            Knowledge__kav article = [ SELECT Id,ArticleNumber,CreatedDate, CreatedById, LastPublishedDate, LastModifiedDate, LastModifiedById,
                 					PublishStatus,Summary,Title,UrlName,VersionNumber,Language,FirstPublishedDate, KnowledgeArticleId
                                   FROM Knowledge__kav WHERE Id =:kavId
            ];
           
            result.Knowledge_Article_Version_Id__c = article.Id;
            result.Knowledge_Article_Id__c = article.KnowledgeArticleId;
            result.Article_Title__c = article.Title;
            result.Article_Created_Date__c = article.CreatedDate;
            result.Article_Created_By__c = article.CreatedById;
            result.Article_Number__c = article.ArticleNumber;
            result.Article_Version__c = article.VersionNumber;
            result.Language__c = article.Language;
            result.Last_Modified_Date__c = article.LastModifiedDate;
            result.Last_Published_Date__c = article.LastPublishedDate;
            result.Last_Modified_By__c = article.LastModifiedById;
            result.Last_Published_By__c = article.LastModifiedById;
            result.Agent__c = article.LastModifiedById;
            result.ArticleFirstPublishedDate__c = article.FirstPublishedDate;
            result.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + article.KnowledgeArticleId;
            result.Name = 'AQI for article '+ article.ArticleNumber +' – '+  article.VersionNumber;
            
			insert result;
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