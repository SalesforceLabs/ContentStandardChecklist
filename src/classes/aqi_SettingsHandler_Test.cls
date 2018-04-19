 /**
 * @author Altimetrik
 * @description
 *	started on January 2018
 *   This class test the aqi_SettingsHandler Class
 **/
@isTest
private class aqi_SettingsHandler_Test {

	//***** Test Methods *****//

    /*
    Description: Check that the getSettings method return an instance of Config Details Setting
    */
	@isTest static void test_getSettings() {
		System.Test.startTest();
		// Implement test code
		ArticleQuality_index__c config   = aqi_SettingsHandler.getSettings();
		System.Test.stopTest();
		system.assertEquals(null,config,'Config details should be null');//
	}

	/*
    Description: Check that the resolveSettings method return an instance of Config Details Setting
    */
	@isTest static void test_resolveSettings() {
		System.Test.startTest();
		//resolve and create
		ArticleQuality_index__c config   = aqi_SettingsHandler.resolveSettings();
		System.Test.stopTest();
		system.assertNotEquals(null,config,'Config details should not be null');
	}
}
