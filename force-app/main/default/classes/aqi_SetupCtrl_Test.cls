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
        Decimal testValue = 9999;
        // Cancel flow
        aqiS.checkForAppConfiguration();
        aqiS.edit();
        Decimal defaultValueBeforeEdit = aqiS.aqs.Possible_Points__c;
        aqiS.aqs.Possible_Points__c = testValue;
        aqiS.cancel();
        Boolean afterCancelWeGetOldValue = defaultValueBeforeEdit ==  aqiS.aqs.Possible_Points__c;
        // Save flow
        aqiS.edit();
        aqiS.aqs.Possible_Points__c = testValue;
        aqiS.save();
        ArticleQuality_index__c currentAqiWithEdition = aqiS.aqs;
        String resultAfterSave = aqi_SetupCtrl.getKnowledgeApiName();
        System.Test.stopTest();
        // Asserts
        System.assert(afterCancelWeGetOldValue,'If we cancel the changes over the custom setting we should get the old value.');
        System.assertEquals(testValue,currentAqiWithEdition.Possible_Points__c,'If we save the changes over the custom setting we should get the new value.');
        System.assertNotEquals('',resultAfterSave,'You should had a Knowledge api name that currently isn\'t available');
    }
}