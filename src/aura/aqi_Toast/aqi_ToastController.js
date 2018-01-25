({
	closeWindow : function(component, event, helper) {
		console.log(' close windos slds-hide ');
		component.set("v.title",'');
		component.set("v.description",'');
		component.set("v.className",'slds-hide');
		component.set("v.severity",'info'); 
	}
})