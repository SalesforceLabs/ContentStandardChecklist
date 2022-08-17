/**
* @author Altimetrik
* @description
* started on January 2018
* Class that resolves logic for custom setting handling
**/
public class aqi_SettingsHandler {
	public static String CUSTOM_SETTING_NAME = 'default';
	public static String DEFAULT_LANGUAGE = 'en_US';
	public static Integer DEFAULT_VALUE = 1;
	public static Integer DEFAULT_POSSIBLE_POINTS = 6;
	public static Boolean DEFAULT_ENABLE_TRIGGER = true;
	public static Boolean DEFAULT_EDIT_ARCHIVED = false;
	public static Boolean DEFAULT_EDIT_DRAFT = true;

	/*
	* @description
	*   Retrieve the default language
	* @params
	*   N/A
	* @return
	*   Return the default language
	*/
	public static String customOrDefaultLanguage() {
		ArticleQuality_index__c  aq = ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME);
		String result = [SELECT LanguageLocaleKey FROM Organization limit 1].LanguageLocaleKey;
		if (aq != null) {
			if (String.isNotBlank(ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME).Selected_Languages__c)) {
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
	*   Return a new clean instance of ArticleQuality_index__c
	*/
	public static ArticleQuality_index__c cleanCS() {
		ArticleQuality_index__c  aq = (aqi_SecurityHandlerLng.isAccessible(ArticleQuality_index__c.sObjectType)) ? ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME) : null;

		if (aqi_SecurityHandlerLng.isCreateable(ArticleQuality_index__c.sObjectType) && aqi_SecurityHandlerLng.isUpdateable(ArticleQuality_index__c.sObjectType)) {
			if (aq == null) {
				aq = new ArticleQuality_index__c(
					Name = CUSTOM_SETTING_NAME,
					Selected_Languages__c  = DEFAULT_LANGUAGE,
					Art_Meets_Content_Standard__c = 0, //Deprecated field
					Article_Unique__c = DEFAULT_VALUE,
					Content_complete__c = DEFAULT_VALUE,
					Content_understandable__c = DEFAULT_VALUE,
					Links_in_article_valid__c = DEFAULT_VALUE,
					Possible_Points__c = DEFAULT_POSSIBLE_POINTS,
					Properties_set_appropriately__c = DEFAULT_VALUE,
					Title_Accurate__c = DEFAULT_VALUE,
					Trigger_Enabled__c = DEFAULT_ENABLE_TRIGGER,
					Prevent_AQI_Edit_on_Archived_Article__c = DEFAULT_EDIT_ARCHIVED,
					Prevent_AQI_Edit_on_Draft_Article__c = DEFAULT_EDIT_DRAFT
				);
			}

			UPSERT aq;
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
	public static ArticleQuality_index__c checkForAppConfiguration() {
		ArticleQuality_index__c  aq;

		if (aqi_SecurityHandlerLng.isAccessible(ArticleQuality_index__c.sObjectType)) {
			aq = ArticleQuality_index__c.getInstance(CUSTOM_SETTING_NAME);

			if (aq == null) {
				aq = new ArticleQuality_index__c(
					Name = CUSTOM_SETTING_NAME,
					Selected_Languages__c  = DEFAULT_LANGUAGE,
					Art_Meets_Content_Standard__c = 0, //Deprecated field
					Article_Unique__c = DEFAULT_VALUE,
					Content_complete__c = DEFAULT_VALUE,
					Content_understandable__c = DEFAULT_VALUE,
					Links_in_article_valid__c = DEFAULT_VALUE,
					Possible_Points__c = DEFAULT_POSSIBLE_POINTS,
					Properties_set_appropriately__c = DEFAULT_VALUE,
					Title_Accurate__c = DEFAULT_VALUE,
					Trigger_Enabled__c = DEFAULT_ENABLE_TRIGGER,
					Prevent_AQI_Edit_on_Archived_Article__c = DEFAULT_EDIT_ARCHIVED,
					Prevent_AQI_Edit_on_Draft_Article__c = DEFAULT_EDIT_DRAFT
				);
			}
		}

		return aq;
	}
}