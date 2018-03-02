({
	backToRecord : function(component) {
		var recordId = component.get("v.recordId");
		window.location.replace( "/" + recordId);  
	}
})
