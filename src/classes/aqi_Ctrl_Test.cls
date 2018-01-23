@isTest
private class aqi_Ctrl_Test {
	
	@isTest static void test_getindexApiNameToValue() {
		// Implement test code
		Map<String,Double>  result = aqi_Ctrl.getindexApiNameToValue();
	
        result = aqi_Ctrl.getindexApiNameToValue();
		system.assertEquals(8,result.size(),'There should be 8 indexes defined');// 
        
        
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}