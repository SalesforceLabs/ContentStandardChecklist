/**
* @author Altimetrik
* @description
*	started on January 2018
*   Test class for aqi_SetupCtrl
**/
@isTest
private class aqi_SetupCtrl_Test {
    @isTest static void cancelAndSave_test() {
        System.Test.startTest();
        aqi_SetupCtrl aqiS = new aqi_SetupCtrl();
        Decimal testValue = 9999;
        // Cancel flow
        aqiS.checkForAppConfiguration();
        aqiS.edit();
        Decimal defaultValueBeforeEdit = aqiS.aqs.Possible_Points__c;
        aqiS.aqs.Possible_Points__c = testValue;
        aqiS.cancel();
        Boolean afterCancelWeGetOldValue = defaultValueBeforeEdit == aqiS.aqs.Possible_Points__c;
        // Save flow
        aqiS.edit();
        aqiS.aqs.Possible_Points__c = testValue;
        aqiS.save();
        ArticleQuality_index__c currentAqiWithEdition = aqiS.aqs;
        System.Test.stopTest();
        
        System.assert(afterCancelWeGetOldValue, 'If we cancel the changes over the custom setting we should get the old value.');
        System.assertEquals(testValue, currentAqiWithEdition.Possible_Points__c, 'If we save the changes over the custom setting we should get the new value.');
    }
}