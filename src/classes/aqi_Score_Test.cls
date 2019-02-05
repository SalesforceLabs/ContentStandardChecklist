/**
* @author Altimetrik
* @description
*	started on January 2019
*   This class test the aqi_Score Trigger
**/
@isTest
private class aqi_Score_Test {
    static SObject kavObj;
    @testSetup static void setup() {
        ArticleQuality_index__c aqs = new ArticleQuality_index__c();
        aqs.name = 'default';
        aqs.Art_Meets_Content_Standard__c  = 1;
        aqs.Article_Unique__c  = 1;
        aqs.Content_complete__c  = 1;
        aqs.Content_understandable__c  = 1;
        aqs.Links_in_article_valid__c  = 1;
        aqs.Properties_set_appropriately__c  = 1;
        aqs.Title_Accurate__c  = 1;
        aqs.Possible_Points__c  = 7;
        aqs.Selected_Languages__c = 'en_US';
        aqs.Trigger_Enabled__c = true;
        insert aqs;
    }
    
    //aux method that insert kav data
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
        kavObj.put('Title','Foo Foo Foo!!!'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('UrlName', 'foo-foo-foo'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
        kavObj.put('Language', default_language);
        insert kavObj;
    }
    
    //***** Test Methods *****//
    
    /*
    Description: Check for the aqi score trigger when the custom setting had the
    */
    @isTest static void test_aqi_Score() {
        
        
        ArticleQuality_index__c aqind =  [Select Id , Trigger_Enabled__c from ArticleQuality_index__c ORDER BY CreatedDate DESC];
        
        // creates Custom Article
        string publishStatus = 'draft';
        insertKavObject();
        // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q =  '    SELECT Id,ArticleNumber,CreatedDate,LastPublishedDate, LastModifiedDate, LastModifiedById,'+
        '    PublishStatus,Summary,Title,UrlName,VersionNumber,Language ,KnowledgeArticleId '+
        '   from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion)Database.query(q);
        KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
        
        ///////////////////////////////////////////////////////////////////////////
        
        //call with valid api name, and record Id
        aqi_LightningResponse resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id,'Article_Unique__c');
        String strR = resp.jsonResponse;
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strR);
        string recordStr = Json.serialize(m.get('aqi_record'));
        Article_Quality__c record = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        record.Article_Unique__c = true;
        recordStr = Json.serialize(record);
        aqi_LightningResponse respSuccess = aqi_ArticleQualityIndexCtrl.upsertAQI(recordStr);
        strR = respSuccess.jsonResponse;
        m = (Map<String, Object>)JSON.deserializeUntyped(strR);
        recordStr = Json.serialize(m.get('aqi_record'));
        Article_Quality__c recordUpserted = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        Article_Quality__c  aqr = [ select Id , Article_Unique__c,AQ_Score__c from Article_Quality__c where Id =:recordUpserted.Id];
        
        String valueTriggerEnabledCheckbox = String.valueOf(recordUpserted.AQ_Score__c);
        /////////////////////////////////////////////////////////////////////////////////////////////
        System.Test.startTest();
        //DISABLE TRIGGER AND REMOVE AQI CHECKBOX SELECTED
        aqind.Trigger_Enabled__c = false;
        upsert aqind;
        //call with valid api name, and record Id
        resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id,'Article_Unique__c');
        strR = resp.jsonResponse;
        m = (Map<String, Object>)JSON.deserializeUntyped(strR);
        recordStr = Json.serialize(m.get('aqi_record'));
        record = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        record.Article_Unique__c = false;
        recordStr = Json.serialize(record);
        respSuccess = aqi_ArticleQualityIndexCtrl.upsertAQI(recordStr);
        strR = respSuccess.jsonResponse;
        m = (Map<String, Object>)JSON.deserializeUntyped(strR);
        recordStr = Json.serialize(m.get('aqi_record'));
        Article_Quality__c recordUpserted2 = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        aqr = [ select Id , Article_Unique__c,AQ_Score__c from Article_Quality__c where Id =:recordUpserted2.Id];
        
        String valueTriggerDisableNoCheckbox = String.valueOf(recordUpserted2.AQ_Score__c);
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        //DISABLE TRIGGER AND REMOVE AQI CHECKBOX SELECTED
        aqind.Trigger_Enabled__c = true;
        upsert aqind;
        //call with valid api name, and record Id
        resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id,'Article_Unique__c');
        strR = resp.jsonResponse;
        m = (Map<String, Object>)JSON.deserializeUntyped(strR);
        recordStr = Json.serialize(m.get('aqi_record'));
        record = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        record.Article_Unique__c = false;
        recordStr = Json.serialize(record);
        respSuccess = aqi_ArticleQualityIndexCtrl.upsertAQI(recordStr);
        strR = respSuccess.jsonResponse;
        m = (Map<String, Object>)JSON.deserializeUntyped(strR);
        recordStr = Json.serialize(m.get('aqi_record'));
        Article_Quality__c recordUpserted3 = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        aqr = [ select Id , Article_Unique__c,AQ_Score__c from Article_Quality__c where Id =:recordUpserted2.Id];
        
        String valueTriggerEnabledNoCheckbox = String.valueOf(recordUpserted3.AQ_Score__c);
        ///////////////////////////////////////////////////////////////////////////////////////////////////////
        
        System.Test.stopTest();
        
        system.assertEquals(true,String.valueOf(valueTriggerEnabledCheckbox).contains('14.28571428571428'));
        system.assertEquals(true,String.valueOf(valueTriggerDisableNoCheckbox).contains('14.28571428571428'));
        system.assertEquals(true,String.valueOf(valueTriggerEnabledNoCheckbox).contains('0'));
    }
}
