({
	doInit : function(component, event, helper) {

		var tmp = JSON.stringify(component.get("v.apiNames"));
		var actionParams ={	recordId: component.get("v.recordId"),
							apiNames :  tmp};
		
		this.handleAction(component, actionParams, 'c.getInitData', this.doInitCallback);

	}
	,

	//Logic to run on success.
	doInitCallback : function(component, responseMap, ctx){
		var that = ctx;

		if (!$A.util.isUndefinedOrNull(responseMap)){
			if(!component.isValid()) return;

			var inputComponents = [];
			var fieldLabel;
			var aqi_fields = responseMap.aqi_fields;
			var aqi_record = responseMap.aqi_record;
			
			component.set('v.aqi_record',aqi_record);
			    
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
				function(components, status, statusMessagesList){
					if(status === "SUCCESS"){
						var fieldsContainer = component.find("fieldsContainer");
						if (fieldsContainer.isValid()){
							var body = fieldsContainer.get("v.body");
							Array.prototype.push.apply(body, components);
							fieldsContainer.set("v.body", body);
						}

						console.log('do Init callback add fields'+body.length);
					}
				}
			);
			
			console.log(responseMap);
		}

	},

	doUpdate : function(component) {

		var aqi_record = component.get("v.aqi_record");
		delete aqi_record['Action_Assigned_To__r'];
		component.set("v.aqi_record",aqi_record);

		var actionParams ={	recordStr :JSON.stringify(aqi_record)};
		console.log('doUpdate');
		console.log(actionParams);
		this.handleAction(component, actionParams, 'c.upsertAQI', this.doUpdateCallback);

	},

	//Logic to run on success.
	doUpdateCallback : function(component, responseMap, ctx){
		var that = ctx;

		if (!$A.util.isUndefinedOrNull(responseMap)){
			console.log('doUpdateCallback');
			console.log(responseMap);
			if(!component.isValid()) return;
			var aqi_record = responseMap.aqi_record;
			component.set('v.aqi_record',aqi_record);
			
		}

	},

	getIndexInputs : function(cmp) {
        return cmp.find("fieldsContainer").find({instancesOf: "c:aqi_Field"})
	}
	
})