/**
 * @author Altimetrik
 * @description
 *	started on MM/DD/YYYY
 *	REPLACE_BY_CLASS_LOGIC_RESPONSABILITIES
 **/
public with sharing class aqi_Ctrl {
	// Constants

	//************************************************************************
	// Properties & data members



	//************************************************************************
	// Methods

	public aqi_Ctrl() {
		
	}

	/*
	* @description
	*	returns AQI index api names and values from custom setting
	* @params
	*	none
	* @return 
	*	Map<String,Double> : api_name, decimal value ( index weight)
	*/
	public static Map<String,Double>  getindexApiNameToValue(){
        ArticleQuality_index__c aqs = ArticleQuality_index__c.getInstance('default');
        Map<String, Schema.SObjectField> allFields = Schema.SObjectType.ArticleQuality_index__c.fields.getMap();

        Map<String,Double> result = new Map<String,Double>();  
        Double idx_val;   
        String idx_api_name;
		if (aqs != null){
			for(String str : allFields.keySet()){  
				Schema.DescribeFieldResult dfr = allFields.get(str).getDescribe();
				idx_api_name = dfr.getName();         	
				if (dfr.getType() ==Schema.DisplayType.DOUBLE ){

					//system.debug('\n'+str+':'+idx_api_name+' - '+dfr.getType());
					system.debug(aqs);
					Object obj = aqs.get(idx_api_name);
					idx_val =  Double.valueOf(obj);   
					//system.debug('\n'+str+':'+idx_api_name+' - '+dfr.getType()+' value '+idx_val);
					result.put(idx_api_name,idx_val);
				}
			}
		}
    

        return result;
    }

	/*
	* @description
	*	returns AQI record if it find a match
	* @params
	*	Id kaId Id if kav article related to current AQI record
	*	String kaLang kav language
	*   String kaVersion version number
	* @return 
	*	Article_Quality__c aqi record
	*/
	public static Article_Quality__c findDupe(Id kaId, String kaLang, String kaVersion){

		try{
 
			aqi_SecurityHandler.canAccess(Article_Quality__c.sObjectType);

			list<Article_Quality__c > kavList = [SELECT
													Action_Assigned_To__c,Action_Date__c,Action_Needed__c,Action_Taken__c,
													AQ_Score__c,Article_Link__c,Article_Number__c,Article_Title__c,
													Article_Created_By__c ,Article_Created_Date__c,
													Article_Type__c,Article_Unique__c,Article_Version__c,
													Art_Meets_Content_Standard__c,Comment__c,Content_Complete__c,
													Content_Understandable__c,Internal_Notes__c,ArticleFirstPublishedDate__c,
													Language__c,Last_Modified_By__c,Last_Modified_Date__c,Last_Published_By__c,
													Last_Published_Date__c,Links_In_Article_Valid__c,Possible_Points__c,
													Properties_Set_Appropriately__c,Title_Accurate__c,Agent__c,Knowledge_Article_Version_Id__c,
													Knowledge_Article_Id__c
											FROM Article_Quality__c
											WHERE
												Knowledge_Article_Id__c =: kaId AND
												Article_Version__c =: Decimal.valueOf(kaVersion) AND
												Language__c =: kaLang
												limit 1];

                if (!kavList.isEmpty())
                    return kavList.get(0);
                else
                    return null;

            }catch(Exception e){
                 ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    e.getMessage()
                ));
            }
            return null;
        }

}