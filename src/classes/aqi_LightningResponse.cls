/**
* @author Altimetrik
* @description
* started on January 2018
* This class its responsible of the interaction with lightning components
**/
public class aqi_LightningResponse {

	@AuraEnabled public String jsonResponse {get; set;}
	@AuraEnabled public String error {get; set;}
	@AuraEnabled public String state {get; set;}

	/*
	* @description
	*	Set the current state as Success
	*/
	public aqi_LightningResponse() {
		this.state = 'SUCCESS';
	}

	/*
	* @description
	*	Set the current state as Error if exist and exception
	*/
	public aqi_LightningResponse(Exception e) {
		this();
		if (e != null) {
			this.state = 'ERROR';
			this.error = e.getMessage();
		}
	}
}
