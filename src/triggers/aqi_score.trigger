trigger aqi_score on Article_Quality__c (before insert, before update) {

	String nm = aqi_Ctrl.getPackagePrefix();
	aqi_SettingsHandler.checkForAppConfiguration();
	ArticleQuality_index__c aqs = aqi_SettingsHandler.checkForAppConfiguration();
	Map<String,Double>  indexValues = aqi_Ctrl.getindexApiNameToValue();
	Article_Quality__c duplicate = null;
	Boolean idx_checked;
	for (Article_Quality__c aq : trigger.new){
		//check for duplicate
		duplicate = aqi_Ctrl.findDupe(aq.Knowledge_Article_Id__c, aq.Language__c, String.valueOf(aq.Article_Version__c));
		if (duplicate == null || ( duplicate!= null &&  Trigger.isUpdate )) {
			decimal totalPoints = 0;
			Decimal aqi_value = 0;
			aq.Possible_Points__c = indexValues.get(nm+'Possible_Points__c');
			indexValues.remove(nm+'Possible_Points__c');
			for (String idx : indexValues.keySet()){
				idx_checked = Boolean.valueOf(aq.get(idx));
				if (idx_checked){
					aqi_value += indexValues.get(idx);
				}
			}
			aq.AQ_Score__c = ((Double)aqi_value * 100) / aq.Possible_Points__c;
		}else{
			aq.Knowledge_Article_Version_Id__c.addError('You have already a Quality Index record for this article version :'+
			' <a href=\'/'+duplicate.Id+'\' > link </a>');
		}
	}


}
