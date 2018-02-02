({
	myAction : function(component, event, helper) {

    },

    doInit: function(cmp, event, helper) {
        var action = cmp.get("c.loadKAVId");

        action.setParams({ recordId: cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            if(!cmp.isValid()) return;
            var state = response.getState();

            if (state === "SUCCESS") {
                var responseMap = response.getReturnValue();
              	cmp.set("v.kavId",responseMap);
				helper.afterInit(cmp,event,helper);

            }
			else if (state === "INCOMPLETE") {
			   // do something
		   }
		   else if (state === "ERROR") {
			   var errors = response.getError();
			   console.log(errors);
		   }
        });
        $A.enqueueAction(action);


    }
})
