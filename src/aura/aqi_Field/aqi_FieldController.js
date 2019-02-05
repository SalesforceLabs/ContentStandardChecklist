({
	doInit : function(component, event, helper) {
		
	},
	
	handleCheckboxChange: function(component, event, helper) {
		var val = component.get("v.fieldValue");
		component.set("v.fieldValue", val);
	}
})
