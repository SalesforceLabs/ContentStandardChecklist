/**
* @author Altimetrik
* @description
*	started on 1/21/2018
*   - this class resolved logic for page aqi_Detail/aqi_Edit
**/
public with sharing class aqi_Ctrl {
	//************************************************************************
	// Constants
	// this also needs to be public to allow setting during unit tests
	public static String DEFAULT_SITE_NAME = Site.getName();

	public static String ARTICLE_STATUS = System.Test.isRunningTest() ? '\'draft\'' : '\'online\'';
	//************************************************************************
	// Properties & data members

	public Id 		kaId;
	public String 	kaLang;
	public String 	kaVersion;
	public Boolean 	saved {get;set;}
	public Boolean 	iserror {get;set;}
	public String 	errortext {get;set;}
	public Boolean 	isCurrentVersion {get;set;}
	public Integer 	latestArticleVersionNumber {get;set;}
	public String 	latestArticleUrl {get;set;}
	public Boolean 	articleNotAvailable {get;set;}
	public Map<String,String> langMap {get;set;}
	public KnowledgeArticleVersion article{get;set;}
	public Article_Quality__c record{get;set;}
	public static Boolean showNoRecordTypeMessage {get;set;}

	/*
	* @description
	*    Returns Map with recordType Id and Name
	* @return Boolean
	*/
	public static Map<Id,String> recordTypesMap{
		get{
			if (recordTypesMap == null) {
				recordTypesMap = aqi_SecurityHandler.getAllowedRecordTypesMap();
				if(recordTypesMap == null){
					recordTypesMap = new Map<Id,String>();
				}
				recordTypesMap.put(null,'This article has no record type');
			}
			return recordTypesMap;
		}
		private set;
	}

	public void setNewRecordAndParameters(){
		record = new Article_Quality__c();

		kaId = escapeString(ApexPages.currentPage().getParameters().get('kaId'));
		kaLang = escapeString(ApexPages.currentPage().getParameters().get('lang'));
		kaVersion = escapeString(ApexPages.currentPage().getParameters().get('version'));
	}

	public aqi_Ctrl(ApexPages.StandardController controller){

		langMap = aqi_KnowledgeSearchCtrl.getActivePicklistOptions('User', 'LanguageLocaleKey');

		Article_Quality__c aqi = (Article_Quality__c)controller.getRecord();
		try{

			aqi_SecurityHandler.canAccess(Article_Quality__c.sObjectType);

			if(aqi.Id != null){
				aqi = [	SELECT Article_Version__c, Language__c , Knowledge_Article_Id__c
				FROM Article_Quality__c
				WHERE id=:aqi.Id ];

				kaId = aqi.Knowledge_Article_Id__c;
				kaLang = aqi.Language__c;
				kaVersion = String.valueOf(aqi.Article_Version__c);
			}
			else{
				setNewRecordAndParameters();
			}
			loadKAVDetails();
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			e.getMessage()
			));
		}

	}

	public aqi_Ctrl() {
		try{
			setNewRecordAndParameters();
			loadKAVDetails();
			aqi_SettingsHandler.checkForAppConfiguration();

		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			e.getMessage()
			));
		}
	}

	//************************************************************************
	// Methods

	/*
	* @description
	*	returns AQI index api names and values from custom setting
	* @params
	*	none
	* @return
	*	Map<String,String> : api_name, label value
	*/
	public static Map<String,String>  getAqiObjectApiNameToLabel(){

		ArticleQuality_index__c aqs = aqi_SettingsHandler.resolveSettings();
		Map<String, Schema.SObjectField> allFields = Schema.SObjectType.Article_Quality__c.fields.getMap();

		Map<String,String> result = new Map<String,String>();
		String idx_api_name;
		String prefix = getPackagePrefix();
		if (aqs != null){
			for(String str : allFields.keySet()){
				Schema.DescribeFieldResult dfr = allFields.get(str).getDescribe();
				idx_api_name = dfr.getName();
				idx_api_name = idx_api_name.replace(prefix,'');
				result.put(idx_api_name,dfr.getLabel());
			}
		}
		return result;
	}







	/*
	* @description
	*	returns AQI index api names and values from custom setting
	* @params
	*	none
	* @return
	*	Map<String,String> : api_name, label value
	*/
	public static Map<String,String>  getindexApiNameToLabel(){

		ArticleQuality_index__c aqs = aqi_SettingsHandler.resolveSettings();
		Map<String, Schema.SObjectField> allFields = Schema.SObjectType.ArticleQuality_index__c.fields.getMap();

		Map<String,String> result = new Map<String,String>();
		String idx_api_name;
		if (aqs != null){
			for(String str : allFields.keySet()){
				Schema.DescribeFieldResult dfr = allFields.get(str).getDescribe();
				idx_api_name = dfr.getName();
				if (dfr.getType() ==Schema.DisplayType.DOUBLE ){
					Object obj = aqs.get(idx_api_name);
					result.put(idx_api_name,dfr.getLabel());
				}
			}
		}
		return result;
	}

	/*
	* @description
	*	returns AQI index api names and values from custom setting
	* @params
	*	none
	* @return
	*	Map<String,Double> : api_name, decimal value ( index weight)
	*/
	public static Map<String,Double>  getindexApiNameToValue(){

		ArticleQuality_index__c aqs = aqi_SettingsHandler.resolveSettings();
		Map<String, Schema.SObjectField> allFields = Schema.SObjectType.ArticleQuality_index__c.fields.getMap();

		Map<String,Double> result = new Map<String,Double>();
		Double idx_val;
		String idx_api_name;
		if (aqs != null){
			for(String str : allFields.keySet()){
				Schema.DescribeFieldResult dfr = allFields.get(str).getDescribe();
				idx_api_name = dfr.getName();
				if (dfr.getType() ==Schema.DisplayType.DOUBLE ){
					Object obj = aqs.get(idx_api_name);
					idx_val =  Double.valueOf(obj);
					result.put(idx_api_name,idx_val);
				}
			}
		}
		return result;
	}

	/*
	* @description
	*	returns AQI record if it find a match
	* @params
	*	Id kaId Id if kav article related to current AQI record
	*	String kaLang kav language
	*   String kaVersion version number
	* @return
	*	Article_Quality__c aqi record
	*/
	public static Article_Quality__c findDupe(Id kaId, String kaLang, String kaVersion){

		try{

			aqi_SecurityHandler.canAccess(Article_Quality__c.sObjectType);

			list<Article_Quality__c > kavList = [SELECT
			Action_Assigned_To__c,Action_Date__c,Action_Needed__c,
			Action_Taken__c,AQ_Score__c,Article_Link__c,Article_Number__c,
			Article_Title__c,Article_Created_By__c ,Article_Created_Date__c,
			Article_Type__c,Article_Unique__c,Article_Version__c,
			Art_Meets_Content_Standard__c,Comment__c,Content_Complete__c,
			Content_Understandable__c,Internal_Notes__c,
			ArticleFirstPublishedDate__c,Language__c,Last_Modified_By__c,
			Last_Modified_Date__c,Last_Published_By__c,
			Last_Published_Date__c,Links_In_Article_Valid__c,Possible_Points__c,
			Properties_Set_Appropriately__c,Title_Accurate__c,Agent__c,
			Knowledge_Article_Version_Id__c, Knowledge_Article_Id__c
			FROM Article_Quality__c
			WHERE
			Knowledge_Article_Id__c =: kaId AND
			Article_Version__c =: Decimal.valueOf(kaVersion) AND
			Language__c =: kaLang
			limit 1];

			if (!kavList.isEmpty())
			return kavList.get(0);
			else
			return null;

		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			e.getMessage()
			));
		}
		return null;
	}


	private boolean loadKAVDetails(){
		//validate access on Kav Type
		Boolean canReadKav = aqi_securityHandler.getKAVPermissions();
		Boolean result = false;

		if ( !String.isNotBlank(kaId)) {
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			'Invalid Knowledge Article.'
			));

			return result;
		}

		langMap = aqi_KnowledgeSearchCtrl.getActivePicklistOptions('User', 'LanguageLocaleKey');
		Map<Id,String> typesMap = aqi_securityHandler.getAllowedRecordTypesMap();

		recordLooKup(kaId,kaLang,kaVersion);

		List<KnowledgeArticleVersion> lKAV =  getArticleByPublishedStatus(ARTICLE_STATUS, kaId , kaLang);

		if (!lKAV.isEmpty()) {
			articleNotAvailable = false;

			if (canReadKav) {
				article = lKAV.get(0);
				result = true;
				if (record.Id == null) {
					record = loadKavDetails( article ,  record);
					result = true;
				} else{
					isCurrentVersion = article.VersionNumber == record.Article_Version__c;
					if (!isCurrentVersion){
						latestArticleVersionNumber =article.VersionNumber;
						latestArticleUrl = URL.getSalesforceBaseUrl().toExternalForm() +
						'/' + article.KnowledgeArticleId +
						'?kavVersion='+article.VersionNumber +
						'&lang='+article.Language;
					}
				}
			}else{
				result = false;
				if (!canReadKAv){
					ApexPages.addMessage(new ApexPages.Message(
					ApexPages.Severity.ERROR,
					'You need permissions to access this Article Type.'
					));
				}
			}
		}else{
			//check if article is in Archived
			lKAV =  getArticleByPublishedStatus('\'Archived\'', kaId , kaLang);
			if (lKAV.isEmpty()){

				//check if article is in draft
				lKAV =  getArticleByPublishedStatus('\'Draft\'', kaId , kaLang);
				if (lKAV.isEmpty()){

					ApexPages.addMessage(new ApexPages.Message(
					ApexPages.Severity.ERROR,
					'The related Knowledge Article was not found.'
					));
				}else{
					ApexPages.addMessage(new ApexPages.Message(
					ApexPages.Severity.WARNING,
					'The related Knowledge Article is in draft.'
					));
				}
			}else{

				ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.WARNING,
				'The related Knowledge Article is archived.'
				));
			}

			result = false;
			articleNotAvailable = true;
		}
		return result;
	}

	public static List<KnowledgeArticleVersion> getArticleByPublishedStatus(String status, String articleId , String articleLanguage){

		string query =  '	SELECT Id,ArticleNumber,CreatedDate, CreatedById, LastPublishedDate, ' +
		'			LastModifiedDate, LastModifiedById, PublishStatus,Summary,Title, ' +
		'			UrlName,VersionNumber,Language,FirstPublishedDate, KnowledgeArticleId '+
		'	FROM KnowledgeArticleVersion ' +
		'	WHERE PublishStatus = '+ status +
		' and KnowledgeArticleId =\''+articleId+'\' '+
		' and Language =  \''+articleLanguage+'\'';

		try{
			aqi_SecurityHandler.canAccess(KnowledgeArticleVersion.sObjectType);

			return Database.query(query);

		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			e.getMessage()
			));
		}
		return null;

	}


	private void recordLooKup(Id kaId, String kaLang, String kaVersion){

		try{
			aqi_SecurityHandler.canAccess(Article_Quality__c.sObjectType);
			Article_Quality__c tmp = findDupe(kaId, kaLang, kaVersion);
			if (tmp != null)
			record = tmp;
		}catch (SecurityException e) {
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			e.getDmlMessage(0)
			));
		}

	}

	public PageReference setErrorOnSave(){
		ApexPages.addMessage(new ApexPages.Message(
		ApexPages.Severity.ERROR,
		'Please specify coaching provided by'
		));
		iserror = true;
		return null;
	}
	public PageReference save(){

		if (!String.isNotBlank(record.Knowledge_Article_Version_Id__c)){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			'Please specify Article Version reference'
			));
			iserror = true;
			return null;
		}


		try{
			if (String.isNotBlank(record.Id))
			aqi_SecurityHandler.canUpdate(Article_Quality__c.sObjectType);
			else
			aqi_SecurityHandler.canCreate(Article_Quality__c.sObjectType);

			upsert record;
			saved = true;
			PageReference ppage = new PageReference('/'+record.id);
			ppage.setRedirect(true);
			return ppage;
		}catch (SecurityException e) {
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			e.getDmlMessage(0)
			));
			iserror = true;
		}
		catch(System.DmlException e) {
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			e.getDmlMessage(0)
			));
			iserror = true;
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(
			ApexPages.Severity.ERROR,
			e.getMessage()
			));
			iserror = true;
		}
		return null;
	}

	private String escapeString(String str){
		String result = null;

		if (String.isNotBlank(str)){
			result = String.escapeSingleQuotes(str.trim());
		}else{
			result ='';
		}

		return result;
	}

	/*
	* @description
	*   retrieves initial details to load input fields on AQI record
	* @params
	*   Id recordId Id of the Knowkedledge version record home page
	* @return
	*   Article_Quality__c record
	*/
	public static Article_Quality__c loadKavDetails(KnowledgeArticleVersion article , Article_Quality__c record){
		//resolve record type
		Id thisIs = article.Id;
		Schema.SObjectType token = thisIs.getSObjectType();
		// Using the token, do a describe
		// and construct a query dynamically.
		Schema.DescribeSObjectResult dr = token.getDescribe();
		String queryString = '';
		String filter = '';
		if(aqi_KnowledgeSearchCtrl.isRecordTypeIdActive){
			filter = 'Id, RecordTypeId';
		}
		else{
			filter = 'Id';
		}
		showNoRecordTypeMessage = !aqi_KnowledgeSearchCtrl.isRecordTypeIdActive;
		aqi_SecurityHandler.canAccess(token);
		queryString = 'SELECT '+ filter +' FROM ' + dr.getName() + '	WHERE ' + ' Id =: thisIs' ;
		sObject obj = Database.query(queryString);
		String recordType = aqi_KnowledgeSearchCtrl.isRecordTypeIdActive ? String.valueOf(obj.get('RecordTypeId')) : '';

		record.Knowledge_Article_Version_Id__c = article.Id;
		record.Knowledge_Article_Id__c = article.KnowledgeArticleId;
		record.Article_Title__c = article.Title;
		record.Article_Created_Date__c = article.CreatedDate;
		record.Article_Created_By__c = article.CreatedById;
		if(aqi_KnowledgeSearchCtrl.isRecordTypeIdActive) {
			record.Article_Type__c = recordType;
		}
		record.Article_Number__c = article.ArticleNumber;
		record.Article_Version__c = article.VersionNumber;
		record.Language__c = article.Language;
		record.Last_Modified_Date__c = article.LastModifiedDate;
		record.Last_Published_Date__c = article.LastPublishedDate;
		record.Last_Modified_By__c = article.LastModifiedById;
		record.Last_Published_By__c = article.LastModifiedById;
		record.Agent__c = article.LastModifiedById;
		record.ArticleFirstPublishedDate__c = article.FirstPublishedDate;
		record.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + article.KnowledgeArticleId;
		record.Name = 'AQI for article '+ article.ArticleNumber +' – '+  article.VersionNumber;

		return record;
	}

	public static String getPackagePrefix(){
		ApexClass ap = [SELECT ApiVersion,Name,NamespacePrefix FROM ApexClass where name='aqi_Ctrl' ];
		return String.isNotBlank(ap.NamespacePrefix)? (ap.NamespacePrefix+'__' ):'';
	}

}
