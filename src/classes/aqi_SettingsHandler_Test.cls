/**
 * @author Altimetrik
 * @description
 *	started on 1/23/2018
 *   - this class implements unit tests for aqi_SettingsHandler
 **/
@isTest
private class aqi_SettingsHandler_Test {
	
	@isTest static void test_getSettings() {
		// Implement test code
		ArticleQuality_index__c config   = aqi_SettingsHandler.getSettings();
		system.assertEquals(null,config,'Config details should be null');// 
	}

	@isTest static void test_isAppConfigured() {
		// Implement test code
	
 		system.assertEquals(false,aqi_SettingsHandler.isAppConfigured(),'App is not configured');// 
        
	}

	@isTest static void test_resolveSettings() {
	 
		//resolve and create
		ArticleQuality_index__c config   = aqi_SettingsHandler.resolveSettings();
		system.assertNotEquals(null,config,'Config details should not be null');// 
		insert config ;
 		system.assertEquals(true,aqi_SettingsHandler.isAppConfigured(),'App is configured');// 
	}
	
	
}