({
	doInit : function (cmp, event, helper){
		var actionParams ={	recordId: cmp.get("v.recordId")};
		this.handleAction(cmp, actionParams, 'c.loadKAVId', this.doInitCallback);
	},
	doInitCallback : function( cmp, response, ctx) {
		if(!cmp.isValid()) return;
		var responseMap = response;
		cmp.set("v.kavId",responseMap);
		ctx.afterInit(cmp,event,ctx);
	},
	afterInit: function(cmp, event, helper)
	{ 
		var actionParams ={	kavIdParameter: cmp.get("v.kavId")};
		this.handleAction(cmp, actionParams, 'c.kavIsArchived', this.afterInitCallback);
	},
	afterInitCallback : function(cmp, responseMap, ctx){
		var responseBool = responseMap;
		if(responseBool){
			var toastCmp =  cmp.find("toastNotif");
			toastCmp.set("v.title",'WARNING');
			toastCmp.set("v.description",'The related Knowledge Article is archived.');
			toastCmp.set("v.className",'');
			toastCmp.set("v.severity",'warning');
		}
	}
})
