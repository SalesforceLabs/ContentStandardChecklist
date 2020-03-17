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
        aqi_TestDataFactory.insertArticleQualitySetting();
    }

    // Aux method that inserts kav data
    private static void insertKavObject() {
        aqi_SecurityHandlerLng.canAccess(KnowledgeArticleVersion.sObjectType);
        kavObj = aqi_TestDataFactory.insertKnowledgeArticle();
    }

    /*
    Description: Check for the fields returned by method that return some compact layout data
    */
    @isTest static void getCompactLayoutData_test() {
        System.Test.startTest();
        insertKavObject();
        Map<String,Object> result = aqi_ArticleQualityIndexCtrl.getCompactLayoutData(((Id) kavObj.get('Id')), new Map<String,Object>());
        System.Test.stopTest();
       
        String languageValue = String.valueOf(kavObj.get('Language'));
        String labelLanguage = '';
		for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
			if(value.getValue() == languageValue) {
				labelLanguage = value.getLabel();
				break;
			}
		}
        
        System.assertEquals(labelLanguage, result.get('articleLanguage'), 'The language returned by CompactLayoutData is not the same as at the beginning');
        System.assertEquals(0, result.get('articleVersion'), 'The article version is not the expected');
    }

    /*
    Description: Check that the apiname and record id are not empty - also check for the state of the get init data
    */
    @isTest static void getInitData_test() {
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
    @isTest static void upsertAQI_test() {
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

        String languageValue = String.valueOf(kavObj.get('Language'));
        String labelLanguage = '';
		for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
			if(value.getValue() == languageValue) {
				labelLanguage = value.getLabel();
				break;
			}
		}

        System.assertEquals(labelLanguage, lst_JsonParse.get('articleLanguage'), 'The language returned by CompactLayoutData is not the same as at the beginning');
        System.assertEquals(0, lst_JsonParse.get('articleVersion'), 'The article version is not the expected');
        System.assertEquals(aqr.Article_Unique__c, record.Article_Unique__c, 'Article unique index should be set to TRUE ');
        System.assertEquals('SUCCESS', resp.State, 'State should be SUCCESS ');
    }

    /*
    Description: Test that the dynamic picklist returned for aqi mustn't be null and also the default value
    */
    @isTest static void dynamicPickList_AQI_test() {
        System.Test.startTest();
        aqi_DynamicPickList_AQI ctr = new aqi_DynamicPickList_AQI();
        VisualEditor.DynamicPickListRows rows = ctr.getValues();
        VisualEditor.DataRow defaultVal = ctr.getDefaultValue();
        System.Test.stopTest();

        System.assert(rows != null, 'Dynamic Picklist for AQI mustn\'t be null');
        System.assert(defaultVal != null, 'Default value for Dynamic Picklist of AQI mustn\'t be null');
    }
}