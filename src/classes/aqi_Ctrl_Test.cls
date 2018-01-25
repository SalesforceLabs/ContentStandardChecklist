@isTest
private class aqi_Ctrl_Test {

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

	@isTest static void test_getIndexApiNameToValue() {
		// Implement test code
		Map<String,Double>  result = aqi_Ctrl.getIndexApiNameToValue();

        result = aqi_Ctrl.getIndexApiNameToValue();
		system.assertEquals(8,result.size(),'There should be 8 indexes defined');//


	}

	static testMethod void test_aqiDupe() {
		populateCustomSetting();
		populateData();
	    System.Test.startTest();
		KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
		PageReference tpageRef = Page.aqi_Edit;
	    Test.setCurrentPage(tpageRef);
	    ApexPages.currentPage().getParameters().put('kavId', article.Id);
	    aqi_Ctrl ctr = new aqi_Ctrl();
	    ctr.record = populateFields ( article);
	    ctr.save();
	    System.Test.stopTest();
	    Article_Quality__c testRecord = [   Select AQ_Score__c ,Properties_Set_Appropriately__c
	                                            from Article_Quality__c
	                                            where
	                                                    Article_Version__c =: article.VersionNumber
	                                                and
	                                                    CreatedById =: UserInfo.getUserId()
	                                            ];
	    system.assertNotEquals(null, testRecord.AQ_Score__c);
	    // check uniqness : same user and article version will result on same record
	    Article_Quality__c testRecord2 = populateFields ( article);
	    Database.SaveResult result = Database.insert(testRecord2, false);
	    // Verify
		// In this case the deletion should have been stopped by the trigger,
		// so verify that we got back an error.
	    System.assert(!result.isSuccess());
	    System.assert(result.getErrors().size() > 0);
	    }


	static testMethod void test_indexDetail() {
        populateCustomSetting();
        populateData();

        System.Test.startTest();
        KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;

        PageReference tpageRef = Page.aqi_Edit;
        Test.setCurrentPage(tpageRef);

   		ApexPages.currentPage().getParameters().put('kaId', article.KnowledgeArticleId);
		ApexPages.currentPage().getParameters().put('lang', article.Language);
        ApexPages.currentPage().getParameters().put('version', String.valueOf(article.VersionNumber));

        aqi_Ctrl ctr = new aqi_Ctrl();

        ctr.record = populateFields ( article);
        system.assertEquals(null, ctr.record.AQ_Score__c);
        ctr.save();


     	System.Test.stopTest();
        Article_Quality__c testRecord = [Select AQ_Score__c ,Properties_Set_Appropriately__c,Knowledge_Article_Id__c from Article_Quality__c where Article_Version__c =: article.VersionNumber and CreatedById =: UserInfo.getUserId()];

        ApexPages.StandardController sc = new ApexPages.StandardController(testRecord);
        aqi_Ctrl ctrDetail = new aqi_Ctrl(sc);

        System.assertEquals(null, ctrDetail.errortext);
        System.assertNotEquals(null, ctrDetail.langMap);
        System.assertEquals(true, ctrDetail.isCurrentVersion);
        System.assertNotEquals(article.VersionNumber, ctrDetail.latestArticleVersionNumber);
        System.assertEquals(null, ctrDetail.latestArticleUrl);
		System.assertEquals(true, aqi_Ctrl.appConfigured);
    }

}
