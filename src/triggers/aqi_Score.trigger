trigger aqi_Score on Article_Quality__c (before insert, before update) {

    String nm = aqi_Ctrl.getPackagePrefix();
    ArticleQuality_index__c aqs = aqi_SettingsHandler.checkForAppConfiguration();
    if(aqs.Trigger_Enabled__c){
        Map<String,Double> indexValues = aqi_Ctrl.getindexApiNameToValue();
        Boolean idx_checked;

        Set<Id> kaIds = new Set<Id>();
        Set<String> kaLangs = new Set<String>();
        Set<Decimal> kaVersions = new Set<Decimal>();

        for (Article_Quality__c aq : trigger.new) {
            kaIds.add(aq.Knowledge_Article_Id__c);
            kaLangs.add(aq.Language__c);
            kaVersions.add(Decimal.valueOf(String.valueOf(aq.Article_Version__c)));
        }

        Map<String,Article_Quality__c> allDuplicates = aqi_Ctrl.findDuplicates(kaIds, kaLangs, kaVersions);
        Article_Quality__c duplicate = new Article_Quality__c();

        for (Article_Quality__c aq : trigger.new) {
            // Check for duplicates
            String key = aq.Knowledge_Article_Id__c + '-' + aq.Language__c + '-' + Decimal.valueOf(String.valueOf(aq.Article_Version__c));
            duplicate = allDuplicates.get(key);

            if (duplicate == null || ( duplicate != null &&  Trigger.isUpdate )) {
                Decimal totalPoints = 0;
                Decimal aqi_value = 0;
                aq.Possible_Points__c = indexValues.get(nm + 'Possible_Points__c');
                indexValues.remove(nm + 'Possible_Points__c');

                for (String idx : indexValues.keySet()) {
                    idx_checked = Boolean.valueOf(aq.get(idx));

                    if (idx_checked) {
                        aqi_value += indexValues.get(idx);
                    }
                }

                aq.AQ_Score__c = ((Double)aqi_value * 100) / aq.Possible_Points__c;
            } else {
                aq.Knowledge_Article_Version_Id__c.addError(
                    'You have already a Quality Index record for this article version :'+
                    ' <a href=\'/'+duplicate.Id+'\' > link </a>'
                );
            }
        }
    }
}
