/**
* @author Altimetrik
* @description
*	started on January 2018
*   This class test the aqi_SetupCtrl Class
**/
@isTest
private class aqi_SetupCtrl_Test {

    //***** Test Methods *****//

    /*
    Description: Check that the Knowledge api name exist
    */
    @isTest static void getKnowledgeApiName() {
        System.Test.startTest();
        aqi_SetupCtrl aqiS = new aqi_SetupCtrl();
        aqiS.edit();
        aqiS.save();
        aqiS.cancel();
        String result = aqi_SetupCtrl.getKnowledgeApiName();
        System.Test.stopTest();
        System.assertNotEquals('',result,'You should had a Knowledge api name that currently isn\'t available');
    }
}
