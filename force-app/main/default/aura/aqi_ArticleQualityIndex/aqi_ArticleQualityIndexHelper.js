({
	doInit : function(component, event, helper) {
		// If there are no fields
		if (!component.get("v.displayFollowUpSection") && component.get("v.noFieldsAvailable")) {
			var btn = component.find('applyButton');
			// Disable apply button
			btn.set("v.disabled", true);
			var btnTop = component.find('applyButtonTop');
			// Disable apply button
			btnTop.set("v.disabled", true);
		} else {
			var tmp = JSON.stringify(component.get("v.apiNames"));
			var actionParams ={	recordId: component.get("v.recordId"),
			apiNames :  tmp};
			
			this.handleAction(component, actionParams, 'c.getInitData', this.doInitCallback);
		}
	},
	
	//Logic to run on success.
	doInitCallback : function(component, responseMap, ctx) {
		var that = ctx;
		if (!$A.util.isUndefinedOrNull(responseMap)) {
			if (!component.isValid()) return;
			var inputComponents = [];
			var fieldLabel;
			var aqi_fields = responseMap.aqi_fields;
			var aqi_fuFields = responseMap.aqi_listApiNamesToLabels;
			var aqi_record = responseMap.aqi_record;
			var relatedInitiallyAgent = responseMap.relatedInitiallyAgent;
			component.set('v.prefixOrg',responseMap.prefixOrg);
			
			if (aqi_record.AQ_Score__c !== undefined && aqi_record.AQ_Score__c !== '') {
				aqi_record.AQ_Score__c = Math.round(aqi_record.AQ_Score__c);
			}
			component.set('v.aqi_record',aqi_record);
			component.set('v.aqi_fuFields',aqi_fuFields);
			
			for (var idx in aqi_fields) {
				var indexObj = aqi_fields[idx];
				var value = aqi_record[indexObj.fieldName];
				var inputCmp = [
					"c:aqi_Field",
					{"aura:id": indexObj.fieldName,
					"fieldLabel": indexObj.fieldLabel,
					"fieldName": indexObj.fieldName,
					"fieldValue" : value}
				];
				inputComponents.push(inputCmp);
			}
			
			$A.createComponents(inputComponents,
				function(components, status, statusMessagesList) {
					if (status === "SUCCESS") {
						var fieldsContainer = component.find("fieldsContainer");
						if (fieldsContainer.isValid()) {
							var body = fieldsContainer.get("v.body");
							Array.prototype.push.apply(body, components);
							fieldsContainer.set("v.body", body);
						}
					}
				}
			);
			
			if (component.get("v.displayFollowUpSection")) {
				var asignedToVar = aqi_record[component.get('v.prefixOrg') + 'Action_Assigned_To__r'];
				if (!(asignedToVar === undefined || asignedToVar === '')) {
					var valuesOwner = [{
						type : 'User',
						id: asignedToVar.Id,
						label: asignedToVar.Name,
						icon : {
							url:asignedToVar.FullPhotoUrl,
							backgroundColor:'65CAE4',
							alt:'User'
						},
						record: asignedToVar.Id,
						placeHolder: 'Search Users'
					}];
					component.find("Action_Assigned_To__c").get("v.body")[0].set("v.values", valuesOwner);
				}
			}
			var agentAssigned = aqi_record[component.get('v.prefixOrg') + 'Agent__r'];
			
			if ((agentAssigned === undefined || agentAssigned === '')) {
				if (!$A.util.isUndefinedOrNull(relatedInitiallyAgent)) {
					agentAssigned = relatedInitiallyAgent;
				} else {
					ctx.showToast('error', 'Article contributor was not found', 'The Article Contributor on the AQI record was not set because the Last Modified By user on the article could not be found.  Please select an Article Contributor.')
				}
			}
			
			if (!$A.util.isUndefinedOrNull(agentAssigned)) {
				var agentValuesOwner = [{
					type : 'User',
					id: agentAssigned.Id,
					label: agentAssigned.Name,
					icon : {
						url:agentAssigned.FullPhotoUrl,
						backgroundColor:'65CAE4',
						alt:'User'
					},
					record: agentAssigned.Id,
					placeHolder: 'Search Users'
				}];
				component.find("Agent__c").get("v.body")[0].set("v.values", agentValuesOwner);
			}
		}
	},
	
	doUpdate : function(component) {
		var aqi_record = component.get("v.aqi_record");
		delete aqi_record[component.get('v.prefixOrg')+'Action_Assigned_To__r'];
		delete aqi_record[component.get('v.prefixOrg')+'Agent__r'];
		if (component.get('v.displayFollowUpSection')) {
			var actionDateC = component.find('Action_Date__c').get('v.value');
			
			if (actionDateC != null && actionDateC === '') {
				aqi_record[component.get('v.prefixOrg')+'Action_Date__c'] = null;
			}
		}
		component.set("v.aqi_record",aqi_record);
		
		var actionParams ={	recordStr :JSON.stringify(aqi_record)};
		
		this.handleAction(component, actionParams, 'c.upsertAQI', this.doUpdateCallback);
	},
	
	//Logic to run on success.
	doUpdateCallback : function(component, responseMap, ctx) {
		var that = ctx;
		var toastCmp;
		var lastToastCmp;
		if (component.get('v.upButtonIsPress')) {
			toastCmp =  component.find("toastNotifUp");
			lastToastCmp =  component.find("toastNotifBot");
		} else {
			toastCmp =  component.find("toastNotifBot");
			lastToastCmp =  component.find("toastNotifUp");
		}
		
		if (!$A.util.isUndefinedOrNull(responseMap)) {
			if (!component.isValid()) return;
			var aqi_record = responseMap.aqi_record;
			var aq_score = aqi_record[component.get('v.prefixOrg')+'AQ_Score__c'];
			if (aq_score !== undefined && aq_score !== '') {
				aq_score = Math.round(aq_score);
			}
			
			component.set('v.aqi_record',aqi_record);
			toastCmp.set("v.title",'AQI Successfully updated');
			toastCmp.set("v.className",'slds-show');
			toastCmp.set("v.severity",'info');
			
			if (!component.get("v.noFieldsAvailable")) {
				toastCmp.set("v.description",'The AQI has been updated. The new score is : '+Math.round(aq_score));
			} else {
				toastCmp.set("v.description",'The AQI has been updated.');
			}
		} else {
			toastCmp.set("v.title",'Warning');
			toastCmp.set("v.description",'ResponseMap empty');
			toastCmp.set("v.className",'slds-show');
			toastCmp.set("v.severity",'warning');
		}
		
		lastToastCmp.set("v.className",'slds-hide');
	},
	
	getIndexInputs : function(cmp) {
		return cmp.find("fieldsContainer").find({instancesOf: "c:aqi_Field"})
	}
})