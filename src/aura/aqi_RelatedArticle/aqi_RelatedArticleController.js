({
	myAction : function(component, event, helper) {

    },
	navigateTo : function(component, event, helper) {

	    //Find the text value of the component with aura:id set to "address"

		var idKav = component.get("v.kavId");
		var sObectEvent = $A.get("e.force:navigateToSObject");
		  sObectEvent .setParams({
		  "recordId": idKav,
		  "slideDevName": "detail"
		 });
		 sObectEvent.fire();

	},
    doInit: function(cmp, event, helper) {

        helper.doInit(cmp, event, helper);

    }
})
