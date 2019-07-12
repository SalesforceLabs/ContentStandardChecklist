({
	doInit : function(component, event, helper) {
		var apiNames= [];
		
		for (var i = 1; i < 11; i++) {
			var field = 'v.indexField' + i;
			
			if  (!$A.util.isUndefinedOrNull(component.get(field)) && component.get(field) !== 'none') {
				apiNames.push(component.get(field));
			}
		}
		
		if (apiNames.length === 0) {
			component.set('v.noFieldsAvailable', true);
		}
		
		component.set("v.apiNames",apiNames);
		helper.doInit(component, event, helper);
	},
	
	updateAQI : function(component, event, helper) {
		var buttonAuraId = event.getSource().getLocalId();
		var followUpExist = component.get("v.displayFollowUpSection");
		var continueWithUpdate = false;
		var advalue = undefined;
		
		if (followUpExist) {
			advalue = component.find('Action_Date__c').get('v.value');
			if (!$A.util.isUndefinedOrNull(advalue)) {
				var splitDateValues = advalue.split('-');
				var lengthOfChars = 0;
				if (splitDateValues.length === 3) {
					lengthOfChars = splitDateValues[0].length + splitDateValues[1].length + splitDateValues[2].length;
					continueWithUpdate = !isNaN(splitDateValues[0]) && !isNaN(splitDateValues[1]) && !isNaN(splitDateValues[2]);
					continueWithUpdate = continueWithUpdate && (splitDateValues[0].length >= 1 && splitDateValues[1].length >= 1 && splitDateValues[2].length >= 1);
					continueWithUpdate = continueWithUpdate && lengthOfChars <= 8;
				}
			}
		}
		
		var aqi_obj = component.get('v.aqi_record');
		var indexInputs = helper.getIndexInputs(component);
		
		if (!indexInputs) return;
		
		if (buttonAuraId === 'applyButtonTop') {
			component.set('v.upButtonIsPress',true);
		} else {
			component.set('v.upButtonIsPress',false);
		}
		
		var lastToastCmp;
		var article_contributor = component.find('Agent__c').get('v.value');
		if (followUpExist) {
			var assignedTo = component.find('Action_Assigned_To__c').get('v.value');
			var wrongAssignedTo = assignedTo === 'MALFORMED_ID';
		}
		
		var wrongArticleContributor = article_contributor === 'MALFORMED_ID';
		if ((continueWithUpdate || $A.util.isUndefinedOrNull(advalue) || advalue === '') && !wrongArticleContributor && !wrongAssignedTo) {
			for (var i = 0; i < indexInputs.length; i++) {
				var aqiIndex = indexInputs[i];
				aqi_obj[aqiIndex.get("v.fieldName")] = aqiIndex.get("v.fieldValue");
			}
			
			if (followUpExist) {
				var actionNeeded = component.find('Action_Needed__c').get('v.value');
				var asignedTo = component.find('Action_Assigned_To__c').get('v.value');
				
				if (component.get('v.upButtonIsPress')) {
					lastToastCmp = component.find("toastNotifBot");
				} else {
					lastToastCmp = component.find("toastNotifUp");
				}
				lastToastCmp.set("v.className",'slds-hide');
				component.set('v.aqi_record',aqi_obj)
				helper.doUpdate(component);
			} else {
				component.set('v.aqi_record',aqi_obj)
				helper.doUpdate(component);
			}
		} else {
			var toastCmp;
			if (component.get('v.upButtonIsPress')) {
				lastToastCmp = component.find("toastNotifBot");
				toastCmp = component.find("toastNotifUp");
			} else {
				lastToastCmp = component.find("toastNotifUp");
				toastCmp = component.find("toastNotifBot");
			}
			
			toastCmp.set("v.title",'Warning');
			
			toastCmp.set("v.description", (wrongArticleContributor || wrongAssignedTo) ? 'No matching users found' : 'Please select a valid Action Date.');
			toastCmp.set("v.className",'slds-show');
			toastCmp.set("v.severity",'warning');
			lastToastCmp.set("v.className",'slds-hide');
		}
	}
})