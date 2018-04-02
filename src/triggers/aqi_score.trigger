trigger aqi_score on Article_Quality__c (before insert, before update) {

	String nm = aqi_Ctrl.getPackagePrefix();
	aqi_SettingsHandler.checkForAppConfiguration();
	ArticleQuality_index__c aqs = aqi_SettingsHandler.getSettings();
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
			system.debug('\n \t\t\t\t\t\t\t\t\t\t ========== AQI : Possible_Points__c ['+nm+'Possible_Points__c'+'] '+indexValues.get(nm+'Possible_Points__c'));
			indexValues.remove(nm+'Possible_Points__c');
			for (String idx : indexValues.keySet()){
				system.debug('\n \t\t\t\t\t\t\t\t\t\t loop   '+aq.get(idx));
				idx_checked = Boolean.valueOf(aq.get(idx));
				if (idx_checked){
					system.debug('\n \t\t\t\t\t\t\t\t\t\t adding   '+idx+' val '+indexValues.get(idx));
					aqi_value += indexValues.get(idx);
				}
			}
			aq.AQ_Score__c = ((Double)aqi_value * 100) / aq.Possible_Points__c;
			system.debug('\n \t\t\t\t\t\t\t\t\t\t AQI : score '+aq.AQ_Score__c);
		}else{
			system.debug('\n====== Test trigger error ');
			aq.Knowledge_Article_Version_Id__c.addError('You have already a Quality Index record for this article version :'+
			' <a href=\'/'+duplicate.Id+'\' > link </a>');
		}
	}


}
