/**
* @author Altimetrik
* @description
*    started on 16/03/2020
*    Test for custom labels reference to be included in package
**/
@isTest
public with sharing class aqi_CustomLabels_Test {
    @isTest
    static void getLabelsTest() {
        System.Test.startTest();
        Boolean result = aqi_CustomLabels.getLabels();
        System.Test.stopTest();

        System.assert(result);
    }
}
