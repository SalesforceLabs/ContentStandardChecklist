({
	doInit : function (cmp, event, helper){
		var actionParams ={	recordId: cmp.get("v.recordId")};
		this.handleAction(cmp, actionParams, 'c.loadKAVId', this.doInitCallback);
	},
	doInitCallback : function( cmp, response, ctx) {
		if(!cmp.isValid()) return;
		cmp.set("v.kavId",response.kavId);
		if(response.isArchived){
			var toastCmp =  cmp.find("toastNotif");
			toastCmp.set("v.title",'WARNING');
			toastCmp.set("v.description",'The related Knowledge Article is archived.');
			toastCmp.set("v.className",'');
			toastCmp.set("v.severity",'warning');
		}
	}  
})