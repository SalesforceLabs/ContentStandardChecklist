/**
 * @author Altimetrik
 * @description
 *  started on 1/22/2018
 *  structure for reponse class used to interact with lightning components
 **/
public class aqi_LightningResponse {

    @AuraEnabled public String jsonResponse {get; set;}
    @AuraEnabled public String error {get; set;}
    @AuraEnabled public String state {get; set;}

    public aqi_LightningResponse() {
        this.state = 'SUCCESS';
    }

    public aqi_LightningResponse(Exception e){
        this();
        if(e != null){
            this.state = 'ERROR';
            this.error = e.getMessage();
        }
    }
}