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
        // because there were no errors 
        // // handle save success 
  		console.log('\n ==== handleSaveSuccess ');
         helper.backToRecord(component);
        
    },
    handleDoneWaiting : function(component, event,helper) {
        // if there were errors during save,
        //  the handleSaveSuccess doesn’t get fired 
        //  if(component.get(“v.isErrorOnSave”) === true) { 
        //  // show the error div 
        //  }
        console.log('\n ==== handleDoneWaiting ');
    }
})