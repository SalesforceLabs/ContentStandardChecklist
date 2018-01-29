({
	doInit : function(component, event, helper) {
		var apiNames= [];

		for(var i = 1; i < 11; i++) {
			var field = 'v.indexField' + i;

			if  (!$A.util.isUndefinedOrNull(component.get(field)) && component.get(field) !== 'none')
				apiNames.push(component.get(field));

			console.log('component.get(field): ' + component.get(field));
		}

		console.log('all api names: ' + apiNames);
		console.log('apiNames.length: ' + apiNames.length);

		if (apiNames.length === 0)
			component.set('v.noFieldsAvailable', true);

		component.set("v.apiNames",apiNames);
		helper.doInit(component, event, helper);

		console.log('do Init');
	},

	updateAQI : function(component, event, helper) {
		var aqi_obj = component.get('v.aqi_record');

		var indexInputs = helper.getIndexInputs(component);
        if (!indexInputs) return;

		var actionNeeded = component.find('Action_Needed__c').get('v.value');
		var asignedTo = component.find('Action_Assigned_To__c').get('v.value');

        for (var i = 0; i < indexInputs.length; i++){
			var aqiIndex = indexInputs[i];
			aqi_obj[aqiIndex.get("v.fieldName")] = aqiIndex.get("v.fieldValue");

			console.log('updateAQI '+aqiIndex.get("v.fieldName")+':'+aqiIndex.get("v.fieldValue"));
		}
		console.log('asignedTo: ' + asignedTo );
		console.log('actionneeded: ' + actionNeeded);
		if (actionNeeded && (asignedTo === undefined || asignedTo === '')){
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
