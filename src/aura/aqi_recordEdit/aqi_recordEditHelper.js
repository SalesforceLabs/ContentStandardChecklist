({
	backToRecord : function(component) {
       /* var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+component.get("v.recordId")
        });
        urlEvent.fire();*/
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.recordId")
        });
        navEvt.fire();
        //$A.get('e.force:refreshView').fire();
        
	}
})