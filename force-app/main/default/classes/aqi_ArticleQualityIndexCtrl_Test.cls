/**
* @author Altimetrik
* @description
*	started on January 2018
*   This class test the aqi_ArticleQualityIndexCtrl Class
**/
@isTest
private class aqi_ArticleQualityIndexCtrl_Test {
    static SObject kavObj;

    @testSetup static void setup() {
        ArticleQuality_index__c aqs = new ArticleQuality_index__c(
            Name = 'default',
            Art_Meets_Content_Standard__c = 5,
            Article_Unique__c = 5,
            Content_complete__c = 5,
            Content_understandable__c = 5,
            Links_in_article_valid__c = 5,
            Properties_set_appropriately__c = 5,
            Title_Accurate__c = 5,
            Possible_Points__c = 35,
            Selected_Languages__c = 'en_US'
        );
       
        INSERT aqs;
    }

    // Aux method that inserts kav data
    private static void insertKavObject() {
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        String default_language = aqi_SettingsHandler.customOrDefaultLanguage();
        List<String> kavNames = new List<String>();
        for (String s : gd.keySet()) {
            if (s.contains('__kav')) {
                kavNames.add(s);
            }
        }

        String objType = kavNames.get(0);
        aqi_SecurityHandlerLng.canAccess(KnowledgeArticleVersion.sObjectType);
        kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
        aqi_SecurityHandlerLng.canAccess(Schema.getGlobalDescribe().get(objType));
        kavObj.put('Title', 'Test Method Title' + String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('UrlName', 'test-method-url-name' + String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Summary', 'Test Method Summary');
        kavObj.put('Language', default_language);
        INSERT kavObj;
    }

    /*
    Description: Check for the fields returned by method that return some compact layout data
    */
    @isTest static void test_Get_CompactLayoutData() {
        System.Test.startTest();
        insertKavObject();
        Map<String,Object> result = aqi_ArticleQualityIndexCtrl.getCompactLayoutData(((Id) kavObj.get('Id')), new Map<String,Object>());
        System.Test.stopTest();
       
        System.assertEquals('English', result.get('articleLanguage'), 'The language returned by CompactLayoutData is not the same as at the beginning');
        System.assertEquals(0, result.get('articleVersion'), 'The article version is not the expected');
    }

    /*
    Description: Check that the apiname and record id are not empty - also check for the state of the get init data
    */
    @isTest static void test_getInitData() {
        System.Test.startTest();
        // Call with null parameters
        aqi_LightningResponse respError1 = aqi_ArticleQualityIndexCtrl.getInitData('', '');
        // Call with valid api name, but empty record Id
        aqi_LightningResponse respError2 = aqi_ArticleQualityIndexCtrl.getInitData('', aqi_Ctrl.getPackagePrefix() + 'Article_Unique__c');
        // Creates Custom Article type
        string publishStatus = 'draft';
        insertKavObject();

        // Require the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q = ' SELECT Id, ArticleNumber, CreatedDate, LastPublishedDate, LastModifiedDate, LastModifiedById,' +
        ' PublishStatus, Summary, Title, UrlName, VersionNumber, Language, KnowledgeArticleId ' +
        ' FROM KnowledgeArticleVersion WHERE Id = \'' + kavObj.get('Id') + '\' AND PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion) Database.query(q);
        KnowledgeArticleVersion article = (KnowledgeArticleVersion) kavObj;
        // Call with valid api name, and record Id
        aqi_LightningResponse respSuccess1 = aqi_ArticleQualityIndexCtrl.getInitData(article.Id, aqi_Ctrl.getPackagePrefix() + 'Article_Unique__c');
        System.Test.stopTest();

        System.assertEquals('ERROR', respError1.State, 'Api names can not be empty');
        System.assertEquals('ERROR', respError2.State, 'Record Id can not be empty');
        System.assertEquals('SUCCESS', respSuccess1.State, 'State should be SUCCESS ');
    }

    /*
    Description: Test the flow of select a kav and create an aqi then test that the get init data its returning the correct values
    */
    @isTest static void test_upsertAQI() {
        System.Test.startTest();
        // Creates Custom Article
        string publishStatus = 'draft';
        insertKavObject();

        // Requires the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q =  ' SELECT Id, ArticleNumber, CreatedDate, LastPublishedDate, LastModifiedDate, LastModifiedById, '+
        ' PublishStatus, Summary, Title, UrlName, VersionNumber, Language, KnowledgeArticleId '+
        ' FROM KnowledgeArticleVersion WHERE Id = \'' + kavObj.get('Id') + '\' AND PublishStatus =: publishStatus';
        kavObj = (KnowledgeArticleVersion) Database.query(q);
        KnowledgeArticleVersion article = (KnowledgeArticleVersion) kavObj;
        
        // Call with valid api name, and record Id
        aqi_LightningResponse resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id, 'Article_Unique__c');
        String strR = resp.jsonResponse;
        Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(strR);
        string recordStr = JSON.serialize(m.get('aqi_record'));
        Article_Quality__c record = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        record.Article_Unique__c = false;
        recordStr = JSON.serialize(record);
        aqi_LightningResponse respSuccess = aqi_ArticleQualityIndexCtrl.upsertAQI(recordStr);
        strR = respSuccess.jsonResponse;
        m = (Map<String,Object>) JSON.deserializeUntyped(strR);
        recordStr = JSON.serialize(m.get('aqi_record'));
        Article_Quality__c recordUpserted = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        Article_Quality__c aqr = [SELECT Id, Article_Unique__c FROM Article_Quality__c WHERE Id =: recordUpserted.Id];
        aqi_LightningResponse responseLKID = aqi_ArticleQualityIndexCtrl.loadKAVId(recordUpserted.Id);
        Map<String,Object> lst_JsonParse = (Map<String,Object>) JSON.deserializeUntyped(responseLKID.jsonResponse);
        System.Test.stopTest();

        System.assertEquals('English', lst_JsonParse.get('articleLanguage'), 'The language returned by CompactLayoutData is not the same as at the beginning');
        System.assertEquals(0, lst_JsonParse.get('articleVersion'), 'The article version is not the expected');
        System.assertEquals(aqr.Article_Unique__c, record.Article_Unique__c, 'Article unique index should be set to TRUE ');
        System.assertEquals('SUCCESS', resp.State, 'State should be SUCCESS ');
    }

    /*
    Description: Test that the dynamic picklist returned for aqi mustn't be null and also the default value
    */
    @isTest static void test_aqi_DynamicPickList_AQI() {
        System.Test.startTest();
        aqi_DynamicPickList_AQI ctr = new aqi_DynamicPickList_AQI();
        VisualEditor.DynamicPickListRows rows = ctr.getValues();
        VisualEditor.DataRow defaultVal = ctr.getDefaultValue();
        System.Test.stopTest();

        System.assert(rows != null, 'Dynamic Picklist for AQI mustn\'t be null');
        System.assert(defaultVal != null, 'Default value for Dynamic Picklist of AQI mustn\'t be null');
    }
}