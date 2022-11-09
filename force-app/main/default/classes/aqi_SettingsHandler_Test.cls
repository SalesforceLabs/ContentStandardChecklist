/**
 * @author Altimetrik
 * @description
 *	started on January 2018
 *   Test class for aqi_SettingsHandler 
 **/
@isTest
private class aqi_SettingsHandler_Test {
	@isTest static void test_checkForAppConfiguration() {
		System.Test.startTest();
		ArticleQuality_index__c config   = aqi_SettingsHandler.checkForAppConfiguration();
		System.Test.stopTest();
		
		System.assertNotEquals(null,config,'Config details shouldn\'t be null');//
	}

	@isTest static void test_cleanCS() {
		System.Test.startTest();
		Decimal testDecimal = 989;
		ArticleQuality_index__c config   = aqi_SettingsHandler.checkForAppConfiguration();
		config.Possible_Points__c = testDecimal;
		config = aqi_SettingsHandler.cleanCS();
		System.Test.stopTest();

		System.assertNotEquals(testDecimal,config.Possible_Points__c,'After clean the custom setting the value shouldn\'t be the same');//
	}
}