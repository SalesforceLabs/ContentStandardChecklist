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
	public static Integer DEFAULT_VALUE 		=  1;
	public static Integer DEFAULT_POSSIBLE_POINTS =  7;
	public static Boolean DEFAULT_ENABLE_TRIGGER = true;

	// Methods

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
	*   Return a new custom setting with all fields cleaned
	* @params
	*   N/A
	* @return
	*   Return a new cleaned instance of ArticleQuality_index__c
	*/
	public static ArticleQuality_index__c cleanCS(){

		ArticleQuality_index__c  aq = (aqi_SecurityHandler.isAccessible(ArticleQuality_index__c.sObjectType)) ? ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME) : null;

		if (aqi_SecurityHandler.isCreateable(ArticleQuality_index__c.sObjectType) && aqi_SecurityHandler.isUpdateable(ArticleQuality_index__c.sObjectType)){
			if(aq == null){
				aq = new ArticleQuality_index__c();
				aq.Name = CUSTOM_SETTING_NAME;
				aq.Selected_Languages__c  = DEFAULT_LANGUAGE;
				aq.Art_Meets_Content_Standard__c = DEFAULT_VALUE;
				aq.Article_Unique__c = DEFAULT_VALUE;
				aq.Content_complete__c = DEFAULT_VALUE;
				aq.Content_understandable__c = DEFAULT_VALUE;
				aq.Links_in_article_valid__c = DEFAULT_VALUE;
				aq.Possible_Points__c = DEFAULT_POSSIBLE_POINTS;
				aq.Properties_set_appropriately__c = DEFAULT_VALUE;
				aq.Title_Accurate__c = DEFAULT_VALUE;
				aq.Trigger_Enabled__c = DEFAULT_ENABLE_TRIGGER;
			}
			upsert aq;
		}
		return aq;
	}

	/*
	* @description
	*   Check for the custom setting, if its not exist a new instance with default values is created.
	* @params
	*   N/A
	* @return
	*   Current or new instance of ArticleQuality_index__c
	*/
	public static ArticleQuality_index__c checkForAppConfiguration(){
		ArticleQuality_index__c  aq;

		if(aqi_SecurityHandler.isAccessible(ArticleQuality_index__c.sObjectType)){
			aq = ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME);
		}
		else{
			aq = null;
		}
		if (aqi_SecurityHandler.isCreateable(ArticleQuality_index__c.sObjectType)){
			if(aq == null){
				aq = new ArticleQuality_index__c();
				aq.Name = CUSTOM_SETTING_NAME;
				aq.Selected_Languages__c  = DEFAULT_LANGUAGE;
				aq.Art_Meets_Content_Standard__c = DEFAULT_VALUE;
				aq.Article_Unique__c = DEFAULT_VALUE;
				aq.Content_complete__c = DEFAULT_VALUE;
				aq.Content_understandable__c = DEFAULT_VALUE;
				aq.Links_in_article_valid__c = DEFAULT_VALUE;
				aq.Possible_Points__c = DEFAULT_POSSIBLE_POINTS;
				aq.Properties_set_appropriately__c = DEFAULT_VALUE;
				aq.Title_Accurate__c = DEFAULT_VALUE;
				aq.Trigger_Enabled__c = DEFAULT_ENABLE_TRIGGER;
			}
		}
		return aq;
	}
}
