@isTest
private class aqi_KnowledgeSearchCtrl_Test {
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
        string publishStatus = 'draft';
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
        kavObj.put('Title','Foo Foo Foo!!!'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('UrlName', 'foo-foo-foo'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
        kavObj.put('Language', default_language);
        insert kavObj;

        // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
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

        aqi_KnowledgeSearchCtrl ctr = new aqi_KnowledgeSearchCtrl();
        System.assertEquals(0,ctr.getMyArticles().size());//without AQI
        System.assertNotEquals(0,aqi_KnowledgeSearchCtrl.allLanguageOptions.size());
        System.assertNotEquals(0,aqi_securityHandler.getAllowedRecordTypesMap().size());
        System.assertNotEquals(0,ctr.getTheRecordTypes().size());

        populateData();

        KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
        ctr.anumber = article.ArticleNumber;
        ctr.author = '';
        ctr.lastpublisher = '';
        ctr.runSearch();

        System.assertNotEquals(null,ctr.getLanguageOptions());
        System.debug('getMyArticle: ' + ctr.getMyArticles().size());
        System.assertEquals(1,ctr.getMyArticles().size());

        System.assertEquals(false,ctr.hasNext);
        System.assertEquals(false,ctr.hasPrevious);
        System.assertEquals(1,ctr.pageNumber);
        ctr.first();
        ctr.last();
        ctr.previous();
        ctr.next();


		ctr.subject = article.Title;
        ctr.author = '';
        ctr.lastpublisher = '';
        ctr.runSearch();
        ctr.updateSort();

        System.assertNotEquals(null,ctr.getLanguageOptions());
        System.assertEquals(0,ctr.getMyArticles().size());


        ctr.dateLastModifiedFrom ='01/01/2015';
        ctr.dateLastModifiedTO ='01/01/2015';
        ctr.dateFirstPublishedFrom ='01/01/2015';
        ctr.dateFirstPublishedTo ='01/01/2015';
        ctr.runSearch();
        System.assertNotEquals(null,ctr.getLanguageOptions());
        System.assertEquals(0,ctr.getMyArticles().size());
        system.assertEquals(true, aqi_KnowledgeSearchCtrl.appConfigured);
     }

}