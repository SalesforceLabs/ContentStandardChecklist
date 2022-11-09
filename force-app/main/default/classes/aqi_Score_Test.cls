/**
* @author Altimetrik
* @description
*	started on January 2019
*   Test class for aqi_Score Trigger
**/
@isTest
private class aqi_Score_Test {
    static SObject kavObj;
    @testSetup static void setup() {
        aqi_TestDataFactory.insertArticleQualitySetting();
    }
    
    // Aux method that insert kav data
    private static void insertKavObject() {
        aqi_SecurityHandlerLng.canAccess(KnowledgeArticleVersion.sObjectType);
        kavObj = aqi_TestDataFactory.insertKnowledgeArticle();
    }
    
    /*
    Description: Check for the aqi score trigger
    */
    @isTest static void test_aqi_Score() {
        ArticleQuality_index__c aqind =  [SELECT Id, Trigger_Enabled__c FROM ArticleQuality_index__c ORDER BY CreatedDate DESC];
        
        // Creates Custom Article
        string publishStatus = 'draft';
        insertKavObject();
        // Require the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q = ' SELECT Id, ArticleNumber, CreatedDate, LastPublishedDate, LastModifiedDate, LastModifiedById,' +
        ' PublishStatus, Summary, Title, UrlName, VersionNumber, Language, KnowledgeArticleId ' +
        ' FROM KnowledgeArticleVersion WHERE Id = \'' + kavObj.get('Id') +  '\' AND PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion) Database.query(q);
        KnowledgeArticleVersion article = (KnowledgeArticleVersion) kavObj;
        
        // Call with valid api name, and record Id
        aqi_LightningResponse resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id, 'Article_Unique__c');
        String strR = resp.jsonResponse;
        Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(strR);
        string recordStr = JSON.serialize(m.get('aqi_record'));
        Article_Quality__c record = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        record.Article_Unique__c = true;
        recordStr = JSON.serialize(record);
        aqi_LightningResponse respSuccess = aqi_ArticleQualityIndexCtrl.upsertAQI(recordStr);
        strR = respSuccess.jsonResponse;
        m = (Map<String,Object>) JSON.deserializeUntyped(strR);
        recordStr = JSON.serialize(m.get('aqi_record'));
        Article_Quality__c recordUpserted = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        Article_Quality__c aqr = [SELECT Id, Article_Unique__c, AQ_Score__c FROM Article_Quality__c WHERE Id =: recordUpserted.Id];
        
        String valueTriggerEnabledCheckbox = String.valueOf(recordUpserted.AQ_Score__c);
        System.Test.startTest();

        // Disable trigger and remove AQI checkbox selected
        aqind.Trigger_Enabled__c = false;
        UPSERT aqind;

        // Call with valid api name, and record Id
        resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id, 'Article_Unique__c');
        strR = resp.jsonResponse;
        m = (Map<String,Object>) JSON.deserializeUntyped(strR);
        recordStr = JSON.serialize(m.get('aqi_record'));
        record = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        record.Article_Unique__c = false;
        recordStr = JSON.serialize(record);
        respSuccess = aqi_ArticleQualityIndexCtrl.upsertAQI(recordStr);
        strR = respSuccess.jsonResponse;
        m = (Map<String,Object>) JSON.deserializeUntyped(strR);
        recordStr = JSON.serialize(m.get('aqi_record'));
        Article_Quality__c recordUpserted2 = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        aqr = [SELECT Id, Article_Unique__c, AQ_Score__c FROM Article_Quality__c WHERE Id =:recordUpserted2.Id];
        
        String valueTriggerDisableNoCheckbox = String.valueOf(recordUpserted2.AQ_Score__c);
        
        // Disable trigger and remove AQI checkbox selected
        aqind.Trigger_Enabled__c = true;
        UPSERT aqind;

        // Call with valid api name, and record Id
        resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id,'Article_Unique__c');
        strR = resp.jsonResponse;
        m = (Map<String,Object>) JSON.deserializeUntyped(strR);
        recordStr = Json.serialize(m.get('aqi_record'));
        record = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        record.Article_Unique__c = false;
        recordStr = Json.serialize(record);
        respSuccess = aqi_ArticleQualityIndexCtrl.upsertAQI(recordStr);
        strR = respSuccess.jsonResponse;
        m = (Map<String,Object>) JSON.deserializeUntyped(strR);
        recordStr = Json.serialize(m.get('aqi_record'));
        Article_Quality__c recordUpserted3 = (Article_Quality__c) System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        aqr = [SELECT Id, Article_Unique__c, AQ_Score__c FROM Article_Quality__c WHERE Id =:recordUpserted2.Id];
        
        String valueTriggerEnabledNoCheckbox = String.valueOf(recordUpserted3.AQ_Score__c);
        System.Test.stopTest();
        
        System.assertEquals(true,String.valueOf(valueTriggerEnabledCheckbox).contains('14.28571428571428'));
        System.assertEquals(true,String.valueOf(valueTriggerDisableNoCheckbox).contains('14.28571428571428'));
        System.assertEquals(true,String.valueOf(valueTriggerEnabledNoCheckbox).contains('0'));
    }
}