/**
* @author Altimetrik
* @description
*	started on January 2018
*   Test class for aqi_LightningResponse
**/
@isTest
private class aqi_LightningResponse_Test {
	private static aqi_LightningResponse lightningResponse = new aqi_LightningResponse();

    @isTest static void test_getAttributes() {
		System.Test.startTest();
        lightningResponse.jsonResponse = 'testJSON';
        lightningResponse.error = 'testERROR';
        lightningResponse.state = 'testSTATE';
		System.Test.stopTest();

        System.assertEquals('testJSON', lightningResponse.jsonResponse, 'jsonResponse should be equal');
        System.assertEquals('testERROR', lightningResponse.error, 'error should be equal');
        System.assertEquals('testSTATE', lightningResponse.state, 'state should be equal');
    }

    @isTest static void test_constructor() {
		System.Test.startTest();
        String state = lightningResponse.state;
		System.Test.stopTest();

        System.assertEquals('SUCCESS', state, 'State should be "SUCCESS"');
    }

    @isTest static void test_exception() {
        try {
			System.Test.startTest();
            User testUser = new User();
            // Insert will fail because there are no required fields set for the user
            INSERT testUser;
        } catch (Exception e) {
            aqi_LightningResponse klr = new aqi_LightningResponse(e);
			System.Test.stopTest();
            System.assertEquals('ERROR', klr.state, 'State should be ERROR');
        }
    }
}