trigger aqi_score on Article_Quality__c (before insert, before update) {


    ArticleQuality_index__c aqs = aqi_SettingsHandler.getSettings();

    Map<String,Double>  indexValues = aqi_Ctrl.getindexApiNameToValue();
   
    if (aqs == null ){
        throw new aqi_SecurityHandler.SecurityException('You need to configure the app');
    }else{
        Article_Quality__c duplicate = null;
        Boolean idx_checked;
        for (Article_Quality__c aq : trigger.new){

            //check for duplicate
            duplicate = aqi_Ctrl.findDupe(aq.Knowledge_Article_Id__c, aq.Language__c, String.valueOf(aq.Article_Version__c));

            if (duplicate == null || ( duplicate!= null &&  Trigger.isUpdate )) {

                decimal totalPoints = 0;
                Decimal aqi_value = 0;
                aq.Possible_Points__c = indexValues.get('Possible_Points__c');
                system.debug('\n \t\t\t\t\t\t\t\t\t\t ========== AQI : Possible_Points__c  '+indexValues.get('Possible_Points__c'));
                indexValues.remove('Possible_Points__c');
                for (String idx : indexValues.keySet()){
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

}