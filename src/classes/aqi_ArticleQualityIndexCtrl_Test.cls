@isTest
private class aqi_ArticleQualityIndexCtrl_Test {
    static SObject kavObj;
    @testSetup static void setup() {
        ArticleQuality_index__c aqs = new ArticleQuality_index__c();
        aqs.name = 'default';
        aqs.Art_Meets_Content_Standard__c  = 5;
        aqs.Article_Unique__c  = 5;
        aqs.Content_complete__c  = 5;
        aqs.Content_understandable__c  = 5;
        aqs.Links_in_article_valid__c  = 5;
        aqs.Properties_set_appropriately__c  = 5;
        aqs.Title_Accurate__c  = 5;
        aqs.Possible_Points__c  = 35;
        aqs.Selected_Languages__c = 'en_US';
        insert aqs;
    }

    @isTest static void test_getInitData() {
        // call with null parameters
        aqi_LightningResponse resp = aqi_ArticleQualityIndexCtrl.getInitData('','');
        system.debug(resp);
        system.assertEquals('ERROR',resp.State ,'Api names can not be empty');

        //call with valid api name, but empty record Id
        resp = aqi_ArticleQualityIndexCtrl.getInitData('','Article_Unique__c');
        system.debug(resp);
        system.assertEquals('ERROR',resp.State ,'Record Id can not be empty');

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
        aqi_SecurityHandler.canAccess(KnowledgeArticleVersion.sObjectType);

        kavObj = Schema.getGlobalDescribe().get(objType).newSObject();

        aqi_SecurityHandler.canAccess(Schema.getGlobalDescribe().get(objType));
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

        KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
        //call with valid api name, and record Id
        resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id,'Article_Unique__c');
        system.debug(resp);
        system.assertEquals('SUCCESS',resp.State ,'State should be SUCCESS ');


    }


    @isTest static void test_upsertAQI() {

      // creates Custom Article
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
        aqi_SecurityHandler.canAccess(Schema.getGlobalDescribe().get(objType));
        aqi_SecurityHandler.canAccess(KnowledgeArticleVersion.sObjectType);
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

        KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
        //call with valid api name, and record Id
        aqi_LightningResponse resp = aqi_ArticleQualityIndexCtrl.getInitData(article.Id,'Article_Unique__c');
        String strR = resp.jsonResponse;
        system.debug(strR);
         Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strR);
        string recordStr = Json.serialize(m.get('aqi_record'));
	 	    Article_Quality__c record = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);
        record.Article_Unique__c = false;
        recordStr = Json.serialize(record);
		    resp = aqi_ArticleQualityIndexCtrl.upsertAQI(recordStr);
        system.debug(resp);
        system.assertEquals('SUCCESS',resp.State ,'State should be SUCCESS ');

        strR = resp.jsonResponse;
        system.debug(strR);
        m = (Map<String, Object>)JSON.deserializeUntyped(strR);
        recordStr = Json.serialize(m.get('aqi_record'));

        Article_Quality__c recordUpserted = (Article_Quality__c)System.JSON.deserializeStrict(recordStr, Article_Quality__c.Class);

        system.debug(recordUpserted.Name);
        Article_Quality__c  aqr = [ select Id , Article_Unique__c from Article_Quality__c where Id =:recordUpserted.Id];
        system.assertEquals(aqr.Article_Unique__c,record.Article_Unique__c ,'Article unique index should be set to TRUE ');


        aqi_LightningResponse responseLKID = aqi_ArticleQualityIndexCtrl.loadKAVId(recordUpserted.Id);
        Map<String,  Object> lst_JsonParse = (Map<String,  Object>)Json.deserializeUntyped(responseLKID.jsonResponse);
    }

    @isTest static void test_aqi_DynamicPickList_AQI() {
      aqi_DynamicPickList_AQI ctr = new aqi_DynamicPickList_AQI();
      VisualEditor.DynamicPickListRows rows = ctr.getValues();
      system.assert(rows!= null);

      VisualEditor.DataRow defaultVal = ctr.getDefaultValue();

      system.assert(defaultVal!= null);

    }
}
