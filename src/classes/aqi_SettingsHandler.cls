/**
* @author Altimetrik
* @description
* started on January 2018
* This class its responsible of resolves logic for custom setting handling
**/
public class aqi_SettingsHandler {
	// Constants
	public static String CUSTOM_SETTING_NAME 	=  'default';
	public static String DEFAULT_LANGUAGE 		=  'en_US';

	// Methods

    /*
    * @description
    *   Retrieve the ArticleQuality_index__c custom setting
    * @params
    *   N/A
    * @return
    *   Return the ArticleQuality_index__c custom setting
    */
	public static ArticleQuality_index__c getSettings(){
		return ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME);
	}

	/*
    * @description
    *   Retrieve the default language
    * @params
    *   N/A
    * @return
    *   Return the default language
    */
	public static String customOrDefaultLanguage(){
		ArticleQuality_index__c  aq = ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME);
		String result = [SELECT LanguageLocaleKey FROM Organization limit 1].LanguageLocaleKey;
		if(aq != null){
			if(String.isNotBlank(ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME).Selected_Languages__c)){
				result = ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME).Selected_Languages__c;
			}
		}
		return result;
	}

	/*
    * @description
    *   Check for the custom setting, if its not exist a new instance with default values is created.
    * @params
    *   N/A
    * @return
    *   N/A
    */
	public static void checkForAppConfiguration(){
		ArticleQuality_index__c  aq = ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME);
		if(aq == null){
			ArticleQuality_index__c  aqToAdd = new ArticleQuality_index__c();
			aqToAdd.Name = CUSTOM_SETTING_NAME;
			insert aqToAdd;
		}
	}

	/*
    * @description
    *   Check for the custom setting, if its not exist return a new instance with default values.
    * @params
    *   N/A
    * @return
    *   N/A
    */
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
