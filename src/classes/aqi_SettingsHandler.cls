/**
 * @author Altimetrik
 * @description
 *	started on 1/23/2018
 *   - this class resolves logic for custom setting handling
 **/
public class aqi_SettingsHandler {

// Constants
	public static String CUSTOM_SETTING_NAME 	=  'default';
	public static String DEFAULT_LANGUAGE 		=  'en_US';


	public static ArticleQuality_index__c getSettings(){
		return ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME);
	}

	public static Boolean isAppConfigured(){
		ArticleQuality_index__c  aq = ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME);

		return (aq != null);
	}

	public static ArticleQuality_index__c resolveSettings(){

		ArticleQuality_index__c aqs = getSettings();
        if (aqs == null){
            aqs  = new ArticleQuality_index__c();
            aqs.name = CUSTOM_SETTING_NAME;
            aqs.Selected_Languages__c  = DEFAULT_LANGUAGE;
		}
		return aqs;
	}

}