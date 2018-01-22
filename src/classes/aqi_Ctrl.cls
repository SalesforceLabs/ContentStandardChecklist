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


}