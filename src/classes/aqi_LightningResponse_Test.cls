@isTest
private class aqi_LightningResponse_Test  {

    private static aqi_LightningResponse lightningResponse = new aqi_LightningResponse();
    @isTest
    static void test_getAttributes() {
        lightningResponse.jsonResponse = 'testJSON';
        lightningResponse.error = 'testERROR';
        lightningResponse.state = 'testSTATE';
        System.assertEquals('testJSON', lightningResponse.jsonResponse, 'jsonResponse should be equal');
        System.assertEquals('testERROR', lightningResponse.error, 'error should be equal');
        System.assertEquals('testSTATE', lightningResponse.state, 'state should be equal');
    }
    @isTest
    static void test_constructor() {
        String state = lightningResponse.state;
        System.assertEquals('SUCCESS', state, 'state should be "SUCCESS"');
    }
    @isTest
    static void test_exception() {
        try {
            User testUser = new User();
            // This insert will fail because there are no required fields set for the user
            insert testUser;
        } catch (Exception e) {
            aqi_LightningResponse klr = new aqi_LightningResponse(e);
            System.assertEquals('ERROR', klr.state, 'State should be ERROR');
        }
    }
}