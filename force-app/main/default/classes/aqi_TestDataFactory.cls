/**
* @author Altimetrik
* @description
*    Started on July 2019
*    Class to create test data
**/
@isTest
public class aqi_TestDataFactory {
    public static SObject insertKnowledgeArticle() {
		// Creates Custom Article type
        String default_language = aqi_SettingsHandler.customOrDefaultLanguage();
		Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
		List<String> kavNames = new List<String>();
		for (String s : gd.keySet()) {
			if (s.contains('__kav')) {
				kavNames.add(s);
			}
		}

		String objType = kavNames.get(0);

		if (gd != null) {
            Schema.DescribeSObjectResult sor = gd.get(objType).getDescribe();
            Map<String,Schema.SObjectField> sofs = sor.fields.getMap();
            Schema.DescribeFieldResult dfr = sofs.get('Language').getDescribe();
            if (dfr != null) {
                List<Schema.PicklistEntry> ples = dfr.getPicklistValues();
                default_language = ples.get(0).getValue();
            }
        }

        aqi_SecurityHandlerLng.canAccess(Schema.getGlobalDescribe().get(objType));
		SObject kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
		kavObj.put('Title', 'Test Method Title' + String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('UrlName', 'test-method-url-name' + String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Summary', 'Test Method Summary' + String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Language', default_language);

		INSERT kavObj;
		return kavObj;
	}

    public static void insertArticleQualitySetting() {
        aqi_SecurityHandlerLng.canAccess(ArticleQuality_index__c.sObjectType);
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

	public static User createUser(Boolean isAdmin) {
		// Create user for test
		Profile prof = [
			SELECT Id 
			FROM Profile 
			WHERE UserType = 'Standard' 
			AND PermissionsCustomizeApplication =: isAdmin 
			AND PermissionsModifyAllData =: isAdmin
			AND PermissionsManageCases = true
			ORDER BY CreatedDate ASC 
			LIMIT 1
		];

		User testUser = new User(
			Alias = 'newUser',
			Email='newuser@testorg.com',
			EmailEncodingKey='UTF-8',
			LastName='Testing',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			ProfileId = prof.Id,
			TimeZoneSidKey='America/Los_Angeles',
			UserName = String.valueOf(Crypto.getRandomInteger()) + 'myusername@testorg.com'
		);

		return testUSer;
	}
}
