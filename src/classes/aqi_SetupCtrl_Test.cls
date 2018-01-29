@isTest
private class aqi_SetupCtrl_Test {

    @isTest static void getKnowledgeApiName() {
        System.Test.startTest();
        aqi_SetupCtrl aqiS = new aqi_SetupCtrl();
        aqiS.edit();
        aqiS.save();
        aqiS.cancel();
        String result = aqi_SetupCtrl.getKnowledgeApiName();
        System.assertNotEquals('',result,'You should had a Knowledge api name that currently isn\'t available');
	    System.Test.stopTest();


    }
}