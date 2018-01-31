@isTest
private class aqi_KnowledgeSearchCtrlV2_Test {
    static SObject kavObj;
    static void populateCustomSetting(){
        //creates a Custom Setting at the organization level
        ArticleQuality_index__c setting= new ArticleQuality_index__c();
        setting.Name = 'default';
        setting.Art_Meets_Content_Standard__c = 2;
        setting.Article_Unique__c = 2;
        setting.Content_complete__c = 2;
        setting.Content_understandable__c = 2;
        setting.Links_in_article_valid__c = 2;
        setting.Possible_Points__c = 2;
        setting.Properties_set_appropriately__c = 2;
        setting.Title_Accurate__c = 4;
        setting.Selected_Languages__c = 'en_US';
        insert setting;
    }

    static void populateData(){
        // creates Custom Article type
        string publishStatus = 'Draft';
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        List<String> kavNames = new List<String>();
        for (String s : gd.keySet()) {
            if (s.contains('__kav')) {
                kavNames.add(s);
            }
        }
        String default_language = aqi_SettingsHandler.customOrDefaultLanguage();
        String objType = kavNames.get(0);
        kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
        kavObj.put('Title','test');
        kavObj.put('UrlName', 'foo-foo-foo-test'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Summary', 'This is a summary test!!! Foo. Foo. Foo.');
        kavObj.put('Language', default_language);
        insert kavObj;
        String q =  '    SELECT Id,ArticleNumber,CreatedDate,LastPublishedDate, LastModifiedDate, LastModifiedById,'+
                    '    PublishStatus,Summary,Title,UrlName,VersionNumber,Language ,KnowledgeArticleId '+
                    '   from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion)Database.query(q);
    }

    static Article_Quality__c populateFields (KnowledgeArticleVersion article){
           Article_Quality__c result = new Article_Quality__c();
           result.Knowledge_Article_Version_Id__c = article.Id;
           result.Article_Title__c = article.Title;
           result.Knowledge_Article_Id__c = article.KnowledgeArticleId;
           result.Article_Number__c = article.ArticleNumber;
           result.Article_Version__c = article.VersionNumber;
           result.Language__c = article.Language;
           result.Last_Modified_Date__c = article.LastModifiedDate;
           result.Last_Published_Date__c = article.LastPublishedDate;
           result.Last_Modified_By__c = article.LastModifiedById;
           result.Properties_Set_Appropriately__c = false;
           result.Article_Link__c = 'https://login.salesforce.com/' + article.Id;
           result.Article_Unique__c = true;
           result.Art_Meets_Content_Standard__c = true;
           result.Content_Complete__c = true;
           result.Agent__c = UserInfo.getUserId();
           return result;
    }

    @isTest static void test_list() {
        populateCustomSetting();
        System.Test.startTest();
        PageReference tpageRef = Page.aqi_KnowledgeSearch;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('kavId', UserInfo.getUserId());
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(0, pageMessages.size());
        aqi_KnowledgeSearchCtrlV2 ctr = new aqi_KnowledgeSearchCtrlV2();
        populateData();
        KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
        Id[] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = article.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<List<SObject>> knowledgeKavSosl = [FIND 'test' IN ALL FIELDS RETURNING Knowledge__kav ( Id, UrlName, createdby.name, lastmodifiedby.name, Language, ArticleNumber, VersionNumber, KnowledgeArticleId,   Title, CreatedDate, FirstPublishedDate, RecordTypeId, RecordType.Name , LastPublishedDate, LastModifiedDate, Summary  WHERE   PublishStatus = 'Draft'  AND  language = 'en_US'    ORDER BY Title DESC  LIMIT 2 OFFSET 0 )];
        System.assertNotEquals(null,knowledgeKavSosl);
        Map<Id,String> availableRecordTypes = ctr.availableRecordTypes;
        String tzOffset = ctr.tzOffset;
        Object resultOfSoqlWithoutStringSearch = aqi_KnowledgeSearchCtrlV2.getArticles('','', article.Language,'','','', '', '','2015-01-01', '', '0', 'Title', false) ;
        System.assertNotEquals(null,resultOfSoqlWithoutStringSearch);
        Object resultOfSoslWithoutStringSearch = aqi_KnowledgeSearchCtrlV2.getArticles('test','', article.Language,'','','', '', '','2015-01-01', '', '0', 'Title', false) ;
        System.assertNotEquals(null,resultOfSoslWithoutStringSearch);
        List<KnowledgearticleVersion> av = new List<KnowledgeArticleVersion>();
        List<Object> listOfAqiRecords = aqi_KnowledgeSearchCtrlV2.checkForAQIRecords(av,'en_US');
        Map<String,String> allLanguage = aqi_KnowledgeSearchCtrlV2.allLanguageOptions;
        Integer pageSize = ctr.pageSize;
        System.assertNotEquals(null, allLanguage);
        System.assertNotEquals(0, allLanguage.size());
        System.Test.stopTest();
     }
}