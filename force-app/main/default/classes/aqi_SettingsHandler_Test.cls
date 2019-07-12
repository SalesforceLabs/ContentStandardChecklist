/**
 * @author Altimetrik
 * @description
 *	started on January 2018
 *   This class test the aqi_SettingsHandler Class
 **/
@isTest
private class aqi_SettingsHandler_Test {
    /*
    Description: Check that the checkForAppConfiguration method return an instance of Config Details Setting
    */
	@isTest static void test_checkForAppConfiguration() {
		System.Test.startTest();
		// Implement test code
		ArticleQuality_index__c config   = aqi_SettingsHandler.checkForAppConfiguration();
		System.Test.stopTest();
		
		system.assertNotEquals(null,config,'Config details shouldn\'t be null');//
	}

	/*
    Description: Check that the checkForAppConfiguration method return an instance of Config Details Setting
    */
	@isTest static void test_cleanCS() {
		System.Test.startTest();
		// Implement test code
		Decimal testDecimal = 989;
		ArticleQuality_index__c config   = aqi_SettingsHandler.checkForAppConfiguration();
		config.Possible_Points__c = testDecimal;
		config = aqi_SettingsHandler.cleanCS();
		System.Test.stopTest();

		System.assertNotEquals(testDecimal,config.Possible_Points__c,'After clean the custom setting the value shouldn\'t be the same');//
	}
}