({
	doInit : function(component, event, helper) {
		var apiNames= [];
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField1")))
			apiNames.push( component.get("v.indexField1"));
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField2")))
			apiNames.push(component.get("v.indexField2"));
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField3")))
			apiNames.push(component.get("v.indexField3"));
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField4")))
			apiNames.push(component.get("v.indexField4"));
		if  (!$A.util.isUndefinedOrNull(component.get("	v.indexField5")))
			apiNames.push(component.get("v.indexField5"));
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField6")))
			apiNames.push(component.get("v.indexField6"));
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField7")))
			apiNames.push(component.get("v.indexField7"));
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField8")))
			apiNames.push(component.get("v.indexField8"));
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField9")))
			apiNames.push(component.get("v.indexField9"));
		if  (!$A.util.isUndefinedOrNull(component.get("v.indexField10")))
			apiNames.push(component.get("v.indexField10"));
			console.log('all api names ');
			console.log(apiNames);

			component.set("v.apiNames",apiNames);




			helper.doInit(component, event, helper);
			console.log('do Init');
	},
	updateAQI : function(component, event, helper) {
		var aqi_obj = component.get('v.aqi_record');

		var indexInputs = helper.getIndexInputs(component);
        if(!indexInputs) return;

		var actionNeeded = component.find('Action_Needed__c').get('v.value');
		var asignedTo = component.find('Action_Assigned_To__c').get('v.value');
		
        for(var i = 0; i < indexInputs.length; i++){
			var aqiIndex = indexInputs[i];
			aqi_obj[aqiIndex.get("v.fieldName")] = aqiIndex.get("v.fieldValue");

			console.log('updateAQI '+aqiIndex.get("v.fieldName")+':'+aqiIndex.get("v.fieldValue"));
		}
		if(actionNeeded && (asignedTo === undefined || asignedTo === '')){
			var toastCmp =  component.find("toastNotif");
			toastCmp.set("v.title",'Error');
			toastCmp.set("v.description",'Please specify coaching provided by');
			toastCmp.set("v.className",'');
			toastCmp.set("v.severity",'warning');
		}
		else{
			console.log('updatedAQI');

			console.log(aqi_obj);
			component.set('v.aqi_record',aqi_obj)
			helper.doUpdate(component);
		}

	}


})
