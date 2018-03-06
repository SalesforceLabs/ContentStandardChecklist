({
	save : function(component, event, helper) {
        component.set("v.isErrorOnSave", true);
    	component.find("edit").get("e.recordSave").fire();
	},

    cancel : function(component, event,helper) {  
         helper.backToRecord(component);

    },
    handleSaveSuccess : function(component, event,helper) {
        component.set("v.isErrorOnSave", false);
        helper.backToRecord(component);
    },
    handleDoneWaiting : function(component, event,helper) {
    }
})
