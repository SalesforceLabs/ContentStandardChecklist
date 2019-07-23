/**
* @author Altimetrik
* @description
*	started on January 2018
*   This class test the aqi_KnowledgeSearchCtrl Class
**/
@isTest
private class aqi_KnowledgeSearchCtrl_Test {
    static SObject kavObj;

    static void populateCustomSetting() {
        //creates a Custom Setting at the organization level
        ArticleQuality_index__c setting= new ArticleQuality_index__c(
            Name = 'default',
            Art_Meets_Content_Standard__c = 2,
            Article_Unique__c = 2,
            Content_complete__c = 2,
            Content_understandable__c = 2,
            Links_in_article_valid__c = 2,
            Possible_Points__c = 2,
            Properties_set_appropriately__c = 2,
            Title_Accurate__c = 4,
            Selected_Languages__c = 'en_US'
        );
        
        INSERT setting;
    }

    static void populateData() {
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
        aqi_SecurityHandlerLng.canAccess(KnowledgeArticleVersion.sObjectType);
        kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
        kavObj.put('Title', 'test');
        kavObj.put('UrlName', 'foo-foo-foo-test'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Summary', 'This is a summary test!!! Foo. Foo. Foo.');
        kavObj.put('Language', default_language);
        INSERT kavObj;

        String q = ' SELECT Id,ArticleNumber,CreatedDate,LastPublishedDate, LastModifiedDate, LastModifiedById,'+
        ' PublishStatus,Summary,Title,UrlName,VersionNumber,Language ,KnowledgeArticleId '+
        ' FROM KnowledgeArticleVersion WHERE Id = \'' +kavObj.get('Id')+  '\' AND PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion)Database.query(q);
    }

    static Article_Quality__c populateFields (KnowledgeArticleVersion article) {
        Article_Quality__c result = new Article_Quality__c(
            Knowledge_Article_Version_Id__c = article.Id,
            Article_Title__c = article.Title,
            Knowledge_Article_Id__c = article.KnowledgeArticleId,
            Article_Number__c = article.ArticleNumber,
            Article_Version__c = article.VersionNumber,
            Language__c = article.Language,
            Last_Modified_Date__c = article.LastModifiedDate,
            Last_Published_Date__c = article.LastPublishedDate,
            Last_Modified_By__c = article.LastModifiedById,
            Properties_Set_Appropriately__c = false,
            Article_Link__c = 'https://login.salesforce.com/' + article.Id,
            Article_Unique__c = true,
            Art_Meets_Content_Standard__c = true,
            Content_Complete__c = true,
            Agent__c = UserInfo.getUserId()
        );

        return result;
    }

    /*
    Description: Check for the articles returned on the initial listing
    */
    @isTest static void test_list() {
        System.Test.startTest();
        populateCustomSetting();
        PageReference tpageRef = Page.aqi_KnowledgeSearch;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('kavId', UserInfo.getUserId());
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        aqi_KnowledgeSearchCtrl ctr = new aqi_KnowledgeSearchCtrl();
        populateData();
        KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
        populateCustomSetting();
        ApexPages.currentPage().getParameters().put('kavId', UserInfo.getUserId());
        Id[] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = article.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        String knowledgeObject = aqi_SecurityHandlerLng.knowledgeObject;
        SObjectType objToken = Schema.getGlobalDescribe().get(knowledgeObject);
        aqi_SecurityHandlerLng.canAccess(objToken);
        Schema.DescribeSObjectResult dr = objToken.getDescribe();
        String queryStringSosl = '';
        if (aqi_KnowledgeSearchCtrl.isRecordTypeIdActive) {
            queryStringSosl =  ' FIND \'test*\' IN ALL FIELDS RETURNING ' + knowledgeObject + ' ( Id, UrlName, createdby.name, lastmodifiedby.name, Language, ArticleNumber, VersionNumber, KnowledgeArticleId,   Title, CreatedDate, FirstPublishedDate, RecordTypeId, RecordType.Name , LastPublishedDate, LastModifiedDate, Summary  WHERE   PublishStatus = \'Draft\'  AND  language = \'en_US\'    ORDER BY Title DESC  LIMIT 2 OFFSET 0)';
        } else {
            queryStringSosl =  ' FIND \'test*\' IN ALL FIELDS RETURNING ' + knowledgeObject + ' ( Id, UrlName, createdby.name, lastmodifiedby.name, Language, ArticleNumber, VersionNumber, KnowledgeArticleId,   Title, CreatedDate, FirstPublishedDate, LastPublishedDate, LastModifiedDate, Summary  WHERE   PublishStatus = \'Draft\'  AND  language = \'en_US\'    ORDER BY Title DESC  LIMIT 2 OFFSET 0)';
        }
        List<List<SObject>> knowledgeKavSosl = search.query(queryStringSosl);
        Map<Id,String> availableRecordTypes = ctr.availableRecordTypes;
        String tzOffset = ctr.tzOffset;
        Object resultOfSoqlWithoutStringSearch = aqi_KnowledgeSearchCtrl.getArticles('', '', article.Language, '', '', '', '', '', '2015-01-01', '', '0', 'Title', false) ;
        Object resultOfSoslWithoutStringSearch = aqi_KnowledgeSearchCtrl.getArticles('test', '', article.Language,'', '', '', '', '', '2015-01-01', '', '0', 'Title', false) ;
        List<KnowledgearticleVersion> av = new List<KnowledgeArticleVersion>();
        List<Object> listOfAqiRecords = aqi_KnowledgeSearchCtrl.checkForAQIRecords(av, 'en_US');
        Map<String,String> allLanguage = aqi_KnowledgeSearchCtrl.allLanguageOptions;
        Integer pageSize = ctr.pageSize;
        System.Test.stopTest();

        System.assertNotEquals(null, knowledgeKavSosl);
        System.assertNotEquals(null, resultOfSoslWithoutStringSearch);
        System.assertNotEquals(null, resultOfSoqlWithoutStringSearch);
        System.assertNotEquals(null, allLanguage);
        System.assertNotEquals(0, allLanguage.size());
        System.assertEquals(0, pageMessages.size());
    }
}