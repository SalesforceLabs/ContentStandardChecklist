({
	doInit : function(component, event) {
		this.handleAction(component, null, 'c.checkPermissionSet', this.doInitCallback);
	},
	
	doInitCallback : function(component, response, ctx) {
		if (!$A.util.isUndefinedOrNull(response)) {
			if(!$A.util.isEmpty(response.SecurityException) && !response.SecurityException) {
				component.set('v.hasNoAccess', false);
			}
		}
	}
})