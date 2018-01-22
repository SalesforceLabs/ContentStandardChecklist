({
	doInit : function(component, event, helper) {
		console.log('INPUT '+component.get("v.fieldName")+'  '+component.get("v.fieldValue"));
	},
	handleCheckboxChange: function(component, event, helper) {
		var val = component.get("v.fieldValue");
		console.log('INPUT handleCheckboxChange '+val);
		component.set("v.fieldValue", val);
	}
})