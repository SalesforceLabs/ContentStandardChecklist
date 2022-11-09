({
	doInit : function (cmp, event, helper) {
		var actionParams ={	recordId: cmp.get("v.recordId")};
		this.handleAction(cmp, actionParams, 'c.loadKAVId', this.doInitCallback);
	},
	
	navigateTo : function(component, event, helper) {
		var idKav = component.get("v.kavId");
		var sObectEvent = $A.get("e.force:navigateToSObject");
		sObectEvent .setParams({
			"recordId": idKav,
			"slideDevName": "detail"
		});
		sObectEvent.fire();
	},
	
	doInitCallback : function( cmp, response, ctx) {
		if (!cmp.isValid()) return;
		cmp.set("v.kavId",response.kavId);
		cmp.set('v.articleVersion',response.articleVersion);
		cmp.set('v.articleLanguage',response.articleLanguage);
		cmp.set('v.articleRecordType',response.articleRecordType);
		cmp.set('v.articleNumber',response.articleNumber);
		cmp.set('v.articlePublishingStatus',response.articlePublishingStatus);
		
		if (response.isArchived) {
			var toastCmp =  cmp.find("toastNotif");
			toastCmp.set("v.title",$A.get("$Label.c.Warning_message"));
			toastCmp.set("v.description",$A.get("$Label.c.Related_Article_archived_error"));
			toastCmp.set("v.className",'');
			toastCmp.set("v.severity",'warning');
		}
	}
})