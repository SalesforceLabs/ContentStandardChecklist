trigger aqi_Score on Article_Quality__c (before insert, before update) {
    String nm = aqi_Ctrl.getPackagePrefix();
    ArticleQuality_index__c aqs = aqi_SettingsHandler.checkForAppConfiguration();

    //GET KNOWLEDGE OBJECT NAME
    String knowledgeObject = '';
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Set<String> keySet = gd.keySet();
    for (String key : keySet) {
        Schema.SObjectType objectType = gd.get(key);
        if (key.endsWith('kav')) {
            knowledgeObject = objectType.getDescribe().getName();
        }
    }
   
    if (aqs.Trigger_Enabled__c) {
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
        // List of article numbers that appears on the current trigger
        Set<String> listOfArticleNumber = new Set<String>();
        // Map of current index related to the article number, article version and article version id
        Map<Integer, Article_Quality__c> mapCurrentAQToData = new Map<Integer, Article_Quality__c>();
        Integer i = 0;

        for (Article_Quality__c aq : trigger.new) {
            // Check for duplicates
            String key = aq.Knowledge_Article_Id__c + '-' + aq.Language__c + '-' + Decimal.valueOf(String.valueOf(aq.Article_Version__c));
            duplicate = allDuplicates.get(key);

            if (duplicate == null || ( duplicate != null &&  Trigger.isUpdate)) {
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
                    System.Label.AQI_duplicate_error + ' :' +
                    ' <a href=\'/'+duplicate.Id+'\' > link </a>'
               );
            }
            String numberA = aq.Article_Number__c;
            // store article number to be retrieve for each AQ without any repetition
            listOfArticleNumber.add(numberA);
            // Store data of each AQ to iterate after the query
            mapCurrentAQToData.put(i, aq);
            i++;

        }

        //GET PUBLISH STATUS BY ARTICLE NUMBER AND VERSION
        String queryS = 'SELECT Id, PublishStatus, VersionNumber, ArticleNumber FROM ' + knowledgeObject;
        queryS += ' WHERE ArticleNumber IN: listOfArticleNumber';
        List<SObject> listArticles = Database.query(queryS);

        Map<Integer, List<SObject>> articleNumberToKavList = new Map<Integer, List<SObject>>();
        //Order the current kav objects by article number
        for (SObject currentKav : listArticles) {
            Integer currentArticleNumber = Integer.valueOf(currentKav.get('ArticleNumber'));
            if (!articleNumberToKavList.containsKey(currentArticleNumber)) {
                List<SObject> listOfKav = new List<SObject>();
                listOfKav.add(currentKav);
                articleNumberToKavList.put(currentArticleNumber, listOfKav);
            } else {
                List<SObject> existingListForArticleNumber = (List<SObject>) articleNumberToKavList.get(currentArticleNumber);
                existingListForArticleNumber.add(currentKav);
                articleNumberToKavList.put(currentArticleNumber, existingListForArticleNumber);
            }
        }

        for (Article_Quality__c currentAQData : mapCurrentAQToData.values()) {
            String kavIDAQI = String.valueOf(currentAQData.Knowledge_Article_Version_Id__c);
            Integer versionAQI = Integer.valueOf(currentAQData.Article_Version__c);
            Integer numberA = currentAQData.Article_Number__c != null ? Integer.valueOf(currentAQData.Article_Number__c) : 0;

            //CHECK IF RELATED ARTICLE IS ARCHIVED
            Boolean foundSameVersion = false;
            Integer actualVersionOfKav = 0;
            List<SObject> listOfArticlesByArticleNumber =  (List<SObject>) articleNumberToKavList.get(numberA);
            Boolean showArchivedError = false;
            Boolean showDraftError = false;
            Boolean dontThrowErrorFoundAnotherVersionRelated = false;
            if (listOfArticlesByArticleNumber != null && !listOfArticlesByArticleNumber.isEmpty()) {
                for (SObject currentSObj : listOfArticlesByArticleNumber) {
                    Integer currentVersionNumber = Integer.valueOf(currentSObj.get('VersionNumber'));
                    if (currentVersionNumber == versionAQI) { 
                        foundSameVersion = true;
                    }
                    if (String.valueOf(currentSObj.get('Id')) == kavIDAQI) {
                        dontThrowErrorFoundAnotherVersionRelated = true;
                        actualVersionOfKav = currentVersionNumber;
                        String currentPublishStatus = String.valueOf(currentSObj.get('PublishStatus'));
                        if (aqs.Prevent_AQI_Edit_on_Archived_Article__c && currentPublishStatus == 'Archived') {
                            showArchivedError = true;
                        }
                        if (aqs.Prevent_AQI_Edit_on_Draft_Article__c && currentPublishStatus == 'Draft') {
                            showDraftError = true;
                        }
                    }
                }
                Article_Quality__c actualRecord = currentAQData.Id != null ? trigger.newMap.get(currentAQData.Id) : currentAQData;
                if (!foundSameVersion && !dontThrowErrorFoundAnotherVersionRelated) {
                    actualRecord.addError(System.Label.Cant_create_AQI_article_not_exists_error);
                } else {
                    if (!foundSameVersion) {
                        //updateTheArticleVersionInAQI
                        actualRecord.Article_Version__c = double.valueOf(actualVersionOfKav);
                        actualRecord.Name = 'AQI for article ' + String.valueOf(numberA) + ' – ' + String.valueOf(actualVersionOfKav);
                    }
                    if (showArchivedError) {
                        actualRecord.addError(System.Label.Cant_create_AQI_article_archived_error);
                    }
                    if (showDraftError) {
                        actualRecord.addError(System.Label.Cant_create_AQI_article_draft_error);
                    }
                }
            }
        }
    }
}