/**
* @author Altimetrik
* @description
*	started on January 2018
*   This class test the aqi_Ctrl Class
**/
@isTest
private class aqi_Ctrl_Test {
	static SObject kavObj;

	static void populateCustomSetting() {
		// Create a Custom Setting at the organization level
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
		setting.Trigger_Enabled__c = true;
		INSERT setting;
	}

	static void populateData() {
		// Create Custom Article type
		String publishStatus = 'draft';

		String default_language = aqi_SettingsHandler.customOrDefaultLanguage();
		aqi_SecurityHandlerLng.canAccess(KnowledgeArticleVersion.sObjectType);
		kavObj = aqi_TestDataFactory.insertKnowledgeArticle();
		
		// Requery the kavObj to get the KnowledgeArticleId on it that is created automatically
		String q = ' SELECT Id, ArticleNumber, CreatedDate, LastPublishedDate, LastModifiedDate, LastModifiedById, '+
		' PublishStatus, Summary, Title, UrlName, VersionNumber, Language, KnowledgeArticleId '+
		' FROM KnowledgeArticleVersion WHERE Id = \'' + kavObj.get('Id') +  '\' and PublishStatus = :publishStatus';
		kavObj = (KnowledgeArticleVersion)Database.query(q);
	}

	static User createTestUser() {
		Profile p = [SELECT Id FROM Profile WHERE UserType = 'Standard' LIMIT 1];
		User testUser = new User(
			Alias = 'newUser',
			Email = 'newuser@testorg.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = p.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = String.valueOf(Crypto.getRandomInteger()) + 'myusername@testorg.com'
		);
		INSERT testUser;

		return testUser;
	}

	static Article_Quality__c populateFields (KnowledgeArticleVersion article) {
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

	@isTest static void recordTypesMap_test() {
		System.Test.startTest();
		Map<Id,String> obtainedRecordTypesMap = aqi_Ctrl.recordTypesMap;
		System.Test.stopTest();

		System.assertEquals(true, obtainedRecordTypesMap.keySet().size() >= 1, 'There should be at least 1 key on the Record Types Map obtained of aqi_Ctrl');
	}

	@isTest static void getIndexApiNameToValue_test() {
		System.Test.startTest();
		Map<String,Double>  result = aqi_Ctrl.getIndexApiNameToValue();
		result = aqi_Ctrl.getIndexApiNameToValue();
		System.Test.stopTest();

		System.assertEquals(8, result.size(), 'There should be 8 indexes defined');
	}

	@isTest static void aqiDupe_test() {
		System.Test.startTest();
		populateCustomSetting();
		populateData();
		System.assertNotEquals(null, kavObj,'An issue has been detected trying to get the knowledge object');
		KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
		PageReference tpageRef = Page.aqi_Edit;
		Test.setCurrentPage(tpageRef);
		ApexPages.currentPage().getParameters().put('kavId', article.Id);
		aqi_Ctrl ctr = new aqi_Ctrl();
		ctr.record = populateFields(article);
		ctr.save();
		System.Test.stopTest();
	
		Article_Quality__c testRecord = [   
			SELECT AQ_Score__c ,Properties_Set_Appropriately__c
			FROM Article_Quality__c
			WHERE Article_Version__c =: article.VersionNumber AND
			CreatedById =: UserInfo.getUserId()
		];
		System.assertNotEquals(null, testRecord.AQ_Score__c);
		
		Article_Quality__c testRecord2 = populateFields(article);
		Database.SaveResult result = Database.insert(testRecord2, false);
		// Verify that there was an error.
		System.assert(!result.isSuccess());
		System.assert(result.getErrors().size() > 0);
	}

	@isTest static void findDuplicates_test() {
		System.Test.startTest();
		User user1 = [SELECT Id FROM User LIMIT 1];

		Article_Quality__c aq = new Article_Quality__c(
			Article_Version__c = 1,
			Language__c = 'esp',
			Agent__c = user1.Id
		);
		INSERT aq;

		Set<String> langs = new Set<String>{'esp'};
		Set<Decimal> versions = new Set<Decimal>{1};

		Map<String,Article_Quality__c> duplicates1 = aqi_Ctrl.findDuplicates(null, null, null);
		Map<String,Article_Quality__c> duplicates2 = aqi_Ctrl.findDuplicates(null, langs, versions);
		System.Test.stopTest();

		System.assertEquals(0, duplicates1.size(), 'Map should not have a value.');
		System.assertEquals(1, duplicates2.size(), 'Map should have at least a value.');
	}

	@isTest static void indexDetail_test() {
		System.Test.startTest();
		populateCustomSetting();
		populateData();
		System.assertNotEquals(null, kavObj,'An issue has been detected trying to get the knowledge object');
		KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
		
		PageReference tpageRef = Page.aqi_Edit;
		Test.setCurrentPage(tpageRef);
		ApexPages.currentPage().getParameters().put('kaId', article.KnowledgeArticleId);
		ApexPages.currentPage().getParameters().put('lang', article.Language);
		ApexPages.currentPage().getParameters().put('version', String.valueOf(article.VersionNumber));
		
		aqi_Ctrl ctr = new aqi_Ctrl();
		ctr.record = populateFields(article);
		System.assertEquals(null, ctr.record.AQ_Score__c);
		ctr.save();
		System.Test.stopTest();
		
		Article_Quality__c testRecord = [
			SELECT AQ_Score__c ,Properties_Set_Appropriately__c,Knowledge_Article_Id__c 
			FROM Article_Quality__c 
			WHERE Article_Version__c =: article.VersionNumber AND 
			CreatedById =: UserInfo.getUserId()
		];
		ApexPages.StandardController sc = new ApexPages.StandardController(testRecord);
		aqi_Ctrl ctrDetail = new aqi_Ctrl(sc);
		System.assertEquals(null, ctrDetail.errortext);
		System.assertNotEquals(null, ctrDetail.langMap);
		System.assertEquals(true, ctrDetail.isCurrentVersion);
		System.assertNotEquals(article.VersionNumber, ctrDetail.latestArticleVersionNumber);
		System.assertEquals(null, ctrDetail.latestArticleUrl);
	}

	@isTest static void setErrorOnSave_test() {
		System.Test.startTest();
		aqi_Ctrl ctr = new aqi_Ctrl();
		ctr.setErrorOnSave();
		System.Test.stopTest();

		System.assertEquals(true, ctr.iserror, 'Error var should be set to true');
	}

	@isTest static void saveError_noKavId_test() {
		aqi_Ctrl ctr = new aqi_Ctrl();

		System.Test.startTest();
		// Create user for test
		User testUser = createTestUser();

		System.runAs(testUser) {
			ctr.save();
		}
		System.Test.stopTest();

		System.assertEquals(true, ctr.iserror, 'Error var should be set to true');
	}

	@isTest static void saveError_Exception_test() {
		populateCustomSetting();
		populateData();
		KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
		PageReference tpageRef = Page.aqi_Edit;
		Test.setCurrentPage(tpageRef);
		ApexPages.currentPage().getParameters().put('kaId', article.KnowledgeArticleId);
		ApexPages.currentPage().getParameters().put('lang', article.Language);
		ApexPages.currentPage().getParameters().put('version', String.valueOf(article.VersionNumber));
		aqi_Ctrl ctr = new aqi_Ctrl();

		System.Test.startTest();
		// Create user for test
		User testUser = createTestUser();

		System.runAs(testUser) {
			ctr.save();
		}
		System.Test.stopTest();

		System.assertEquals(true, ctr.iserror, 'Error var should be set to true');
	}
}