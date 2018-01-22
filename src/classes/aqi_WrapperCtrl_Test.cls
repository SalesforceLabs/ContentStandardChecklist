@isTest
private class aqi_WrapperCtrl_Test {
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
        insert aqs;

        
  
       
    }


    @isTest static void test_getInitData() {
        // call with null parameters
        aqi_LightningResponse resp = aqi_WrapperCtrl.getInitData('','');
        system.debug(resp);
        system.assertEquals('ERROR',resp.State ,'Api names can not be empty');

        //call with valid api name, but empty record Id
        resp = aqi_WrapperCtrl.getInitData('','Article_Unique__c');
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

        String default_language = [SELECT LanguageLocaleKey FROM Organization limit 1].LanguageLocaleKey;
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
        system.debug('\n==========');
        system.debug(kavObj);

        KnowledgeArticleVersion article = (KnowledgeArticleVersion)kavObj;
        system.debug('\n==========');
        system.debug(article);
        //call with valid api name, and record Id
        resp = aqi_WrapperCtrl.getInitData(article.Id,'Article_Unique__c');
        system.debug(resp);
        system.assertEquals('SUCCESS',resp.State ,'State should be SUCCESS ');

        
    }
    
    @isTest static void test_method_two() {
        // Implement test code
    }
    
}