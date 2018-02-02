({
	afterInit: function(cmp, event, helper)
	{
		var actionIsArchived = cmp.get("c.kavIsArchived");
		actionIsArchived.setParams({ kavIdParameter:  cmp.get("v.kavId")});
		actionIsArchived.setCallback(this, function(response) {
			var responseBool = response.getReturnValue();
			if(responseBool){
				var toastCmp =  cmp.find("toastNotif");
				toastCmp.set("v.title",'WARNING');
				toastCmp.set("v.description",'The related Knowledge Article is archived.');
				toastCmp.set("v.className",'');
				toastCmp.set("v.severity",'warning'); 
			}
		});
		$A.enqueueAction(actionIsArchived);
	}
})
