/**
* @author Altimetrik
* @description
* started on January 2018
* Class responsible of returning articles filtered by the parameters received by the search and return some values used on the visualforce page
**/
global with sharing class aqi_KnowledgeSearchCtrl {
	public static String PUBLISH_STATUS = System.Test.isRunningTest() ? 'Draft' : 'Online';
	public final static String DEFAULT_LANGUAGE = aqi_SettingsHandler.customOrDefaultLanguage();
	public static final Integer PAGE_SIZE 	= 10;
	public static String sortBy = 'Title';
	public static Boolean sortAsc = false;
	public static String knowledgeObject = aqi_securityHandlerLng.knowledgeObject;
	public static Boolean isValidationStActive = aqi_SecurityHandlerLng.checkForSchemaFieldActive('validationstatus');
	public static Boolean isRecordTypeIdActive = aqi_SecurityHandlerLng.checkForSchemaFieldActive('recordtypeid');

	/*
	* @description
	*	Get the String of the current time zone offset
	*/
	public String tzOffset{
		get {
			if (tzOffset == null) {
				TimeZone tz =  UserInfo.getTimeZone();
				Long ofsetD = tz.getoffset(System.now());
				Time t = Time.newInstance(0, 0, 0, Integer.valueOf(Math.abs(ofsetD)));
				if (t.minute() >= 45) {
					tzOffset = t.hour() + '.8';
				} else if (t.minute() >= 30) {
					tzOffset = t.hour() + '.5';
				} else {
					tzOffset = t.hour() + '.0';
				}
				
				tzOffset = (ofsetD < 0) ? '-' + tzOffset : tzOffset;
			}

			return String.escapeSingleQuotes(tzOffset);
		}	
		set;
	}

	/*
	* @description
	*	Get the boolean of isValidationStatusActive
	*/
	public Boolean isValidationStatusActive {
		get {
			if (isValidationStatusActive == null) {
				isValidationStatusActive = aqi_SecurityHandlerLng.checkForSchemaFieldActive('validationstatus');
			}

			return isValidationStatusActive;
		}
		set;
	}

	/*
	* @description
	*	Get the map<Id,String> of availableRecordTypes
	*/
	public Map<Id,String> availableRecordTypes {
		get {
			if (availableRecordTypes == null) {
				availableRecordTypes = aqi_SecurityHandlerLng.getAllowedRecordTypesMap();
			}

			return availableRecordTypes;
		}
		set;
	}

	/*
	* @description
	*	Get the pagesize
	*/
	public Integer pageSize {
		get {
			return PAGE_SIZE;
		}
		set;
	}

	/*
	* @description
	*	Method that retrieve list of available languages
	* @params
	*	N/A
	* @return
	*	Returns list of available languages
	*/
	public static map<String,String> allLanguageOptions {
		get {
			if (allLanguageOptions == null) {
				Set<String> availableLanguages = new Set<String>();
				String settingsLanguages = aqi_SettingsHandler.checkForAppConfiguration().Selected_Languages__c;
				availableLanguages.addAll(settingsLanguages.split(','));
				Map<String,String> optionsMap = getActivePicklistOptions('User', 'LanguageLocaleKey');
				allLanguageOptions = new Map<String,String>();

				for (String s : availableLanguages) {
					s = s.trim();
					if (optionsMap.containsKey(s)) {
						allLanguageOptions.put(s, optionsMap.get(s));
					}
				}
			}

			return allLanguageOptions;
		}
		private set;
	}

	/*
	* @description
	*	Method that return the current offset
	* @params
	*	String page number
	* @return
	*	Return that return the current offset
	*/
	public static Integer resolveOffset(String p) {
		Integer queryOffset = 0;
		if (String.isNotBlank(p)) {
			Integer pageNum = Integer.valueOf(p);
			if (pageNum>0) {
				queryOffset = (pageNum) * PAGE_SIZE;
			}
		}

		return queryOffset;
	}

	/*
	* @description
	*	Method that return a list of kavs filtered by the parameters received
	* @params
	*	String searchString, String articleNumber and String articleLanguage
	* @return
	*	Return List of kavs filtered by the parameters received
	*/
	@RemoteAction
	global static Object getArticles(String searchString, String articleNumber, String articleLanguage,
	String articleCreatedBy, String articlelastModifiedBy, String articleRecordType, String articlePublishDateFrom, 
	String articlePublishDateTo, String articleLastModifiedDateFrom, String articleLastModifiedDateTo,
	String pageNum, String sortBy, Boolean sortAsc) {
		Integer queryOffset =  resolveOffset(pageNum);
		Boolean isMasterLanguage = aqi_SecurityHandlerLng.checkForSchemaFieldActive('ismasterlanguage');
		String fieldsToRetrieve = '';
		if (isRecordTypeIdActive) {
			fieldsToRetrieve = ' Id, UrlName, createdby.name, lastmodifiedby.name, Language, ArticleNumber, VersionNumber, KnowledgeArticleId,  '+
			' Title, CreatedDate, FirstPublishedDate, RecordTypeId, RecordType.Name , LastPublishedDate, LastModifiedDate, Summary ';
		} else {
			fieldsToRetrieve = ' Id, UrlName, createdby.name, lastmodifiedby.name, Language, ArticleNumber, VersionNumber, KnowledgeArticleId,  '+
			' Title, CreatedDate, FirstPublishedDate, LastPublishedDate, LastModifiedDate, Summary ';
		}
		if (isValidationStActive) {
		 fieldsToRetrieve += ', ValidationStatus ';
		}
		List<String> whereConditions = new list<String>();
		List<String> errorsOnInput = new list<String>();
		if (String.isNotBlank(searchString)) {
			if (searchString.length() < 2) {
				errorsOnInput.add(System.Label.Search_criteria_error);
			}
		}
		// Validate Article Number
		if (String.isNotBlank(articleNumber)) {
			if (!articleNumber.isNumeric()) {
				errorsOnInput.add(System.Label.Article_number_error);
			} else {
				whereConditions.add(' articlenumber LIKE \'%' + escapeString(articleNumber) + '%\' ');
			}
		}
		// Check if RecordTypeId exists
		if (isRecordTypeIdActive && String.isNotBlank(articleRecordType) & (articleRecordType !='all')) {
			whereConditions.add(' RecordTypeId = \'' + escapeString(articleRecordType) + '\' ');
		}
		// Check Master Language
		if (isMasterLanguage) {
			whereConditions.add(' IsMasterLanguage = true ');
		}
		
		whereConditions.add(' PublishStatus=\''+ PUBLISH_STATUS +'\'');
		whereConditions.add(' language =\'' + escapeString(articleLanguage) + '\' ');

		if (String.isNotBlank(articleCreatedBy)) {
			whereConditions.add(' createdby.name LIKE \'%' + escapeString(articleCreatedBy) + '%\' ');
		}

		if (String.isNotBlank(articlelastModifiedBy)) {
			whereConditions.add(' lastmodifiedby.name LIKE \'%' + escapeString(articlelastModifiedBy) + '%\' ');
		}

		String aux;
		DateTime auxdt;
		DateTime auxDTT_from = strToDateTime(escapeString(articleLastModifiedDateFrom),false);
		DateTime auxDTT_to = strToDateTime(escapeString(articleLastModifiedDateTo),true);
		if (auxDTT_from != null && auxDTT_to!= null) {
			if (auxDTT_from > auxDTT_to) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.Last_Modified_date_invalid_error));
				return '';
			}
		}

		if (auxDTT_from != null) {
			aux = auxDTT_from.formatGMT('yyyy-MM-dd') + 'T' + auxDTT_from.formatGMT('HH:mm:ss.SSS') + 'Z';
			whereConditions.add(' LastModifiedDate >= ' + aux);
		}

		if (auxDTT_to != null) {
			aux = auxDTT_to.formatGMT('yyyy-MM-dd') + 'T' + auxDTT_to.formatGMT('HH:mm:ss.SSS') + 'Z';
			whereConditions.add(' LastModifiedDate <= ' + aux);
		}

		auxDTT_from = strToDateTime(escapeString(articlePublishDateFrom),false);
		auxDTT_to = strToDateTime(escapeString(articlePublishDateTo),true);
		if (auxDTT_from != null && auxDTT_to != null) {
			if (auxDTT_from > auxDTT_to) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.First_Published_date_invalid_error));
				return '';
			}
		}
		if (auxDTT_from != null) {
			aux = auxDTT_from.formatGMT('yyyy-MM-dd') + 'T' + auxDTT_from.formatGMT('HH:mm:ss.SSS') + 'Z';
			whereConditions.add(' FirstPublishedDate >= ' +   aux);
		}
		if (auxDTT_to != null) {
			aux = auxDTT_to.formatGMT('yyyy-MM-dd') + 'T' + auxDTT_to.formatGMT('HH:mm:ss.SSS') + 'Z';
			whereConditions.add(' FirstPublishedDate <= ' + aux);
		}

		String whereClause = ' WHERE  ' + String.join(whereConditions,' AND ');
		String orderByClause = ' ORDER BY '+String.escapeSingleQuotes(sortBy)  ;
		orderByClause += sortAsc ? ' ASC ' : ' DESC '  ;
		String  limitClause = ' LIMIT :PAGE_SIZE OFFSET :queryOffset ';
		String queryString = '';
		List<sObject> sObjList;

		if (errorsOnInput.isEmpty()) {
			if (String.isNotBlank(searchString)) {
				queryString = ' FIND \'' + String.escapeSingleQuotes(searchString) + '*\' IN ALL FIELDS RETURNING ' + knowledgeObject + ' ( ' + fieldsToRetrieve + whereClause + orderByClause + limitClause + ')';
				List<List<SObject>> articlesQueried = search.query(queryString);
				sObjList = ((List<Sobject>) articlesQueried[0]);
			} else {
				queryString = ' SELECT  ' + fieldsToRetrieve + ' FROM ' + knowledgeObject + whereClause + orderByClause + limitClause;
				sObjList = Database.query(queryString);
			}
		}

		List<Object> resultList = checkForAQIRecords(sObjList,escapeString(articleLanguage));
		Map<String,Object> result = new Map<String,Object>();
		result.put('success', true);
		result.put('items', resultList);
		result.put('pageNum', pageNum);
		result.put('errorList', errorsOnInput);
		Boolean showNext = true;
		if (resultList.size() < PAGE_SIZE) {
			showNext = false;
		}
		result.put('showNext',showNext);

		return result;
	}

	/*
	* @description
	*	Method that return a list of kavs and the information of the related aqi
	* @params
	*	List<SObject> kavList, String lang
	* @return
	*	List of kavs and the information of the related aqi
	*/
	public static List<Object> checkForAQIRecords(List<SObject> kavList, String lang) {
		List<Object> result = new List<Object>();
		// Check if this article already has an AQI related
		Set<Id> kavIds = new Set<Id>();
		Set<Decimal> versions = new Set<Decimal>();
		for (SObject sobj : kavList) {
			kavIds.add(String.valueOf(sobj.get('KnowledgeArticleId')));
			versions.add(Decimal.valueOf(String.valueOf(sobj.get('VersionNumber'))));
		}

		List<Article_Quality__c> aqis = new List<Article_Quality__c>();

		if (aqi_SecurityHandlerLng.isCreateable(Article_Quality__c.sObjectType)) {
			aqis = [
				SELECT Id, Knowledge_Article_Id__c, Language__c, Article_Version__c
				FROM Article_Quality__c
				WHERE Knowledge_Article_Id__c in: kavIds
				AND Language__c =: lang
				AND Article_Version__c in: versions
			];
		}

		Map<String,Article_Quality__c> mapAqi = new Map<String, Article_Quality__c>();
		for (Article_Quality__c aqi : aqis) {
			mapAqi.put(aqi.Knowledge_Article_Id__c + aqi.Language__c + aqi.Article_Version__c, aqi);
		}

		String tmpK;
		for (SObject sObj : kavList) {
			String jString = JSON.serialize(sObj);
			Map<String,Object> m = (Map<String,Object>)JSON.deserializeUntyped(jString);
			tmpK = String.valueOf(sobj.get('KnowledgeArticleId')) + lang + Decimal.valueOf(String.valueOf(sobj.get('VersionNumber')));
			m.put('hasAQI', mapAqi.containsKey(tmpK));
			m.put('isValidationStatusEnabled', isValidationStActive);
			result.add(m);
		}

		return result;
	}

	/*
	* @description
	*	Method that escapes the string
	* @params
	*	N/A
	* @return
	*	String
	*/
	private static String  escapeString(String str) {
		String result = null;
		if (String.isNotBlank(str)) {
			result = String.escapeSingleQuotes(str.trim());
		} else {
			result ='';
		}

		return result;
	}

	/*
	* @description
	*	Method that return a map with the active picklist options
	* @params
	*	Set of Ids, Set of Decimal
	* @return
	*	Map<String,String>
	*/
	public static Map<String,String> getActivePicklistOptions(String so, String field) {
		Map<String,String> options = new Map<String,String>();
		for (Schema.PicklistEntry ple : getActivePicklistEntries(so, field)) {
			options.put(ple.getValue(), ple.getLabel());
		}

		return options;
	}

	/*
	* @description
	*	Method that return a List with the active picklist entries
	* @params
	*	Set of Ids, String Field
	* @return
	*	List<Schema.PicklistEntry>
	*/
	public static List<Schema.PicklistEntry> getActivePicklistEntries(String so, String field) {
		Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
		List<Schema.PicklistEntry> ples = new List<Schema.PicklistEntry>();
		// Return empty list if object name was not found in the schema
		if (!gd.containsKey(so)) {
			return ples;
		} 

		Schema.DescribeSObjectResult sor = gd.get(so).getDescribe();
		Map<String,Schema.SObjectField> sofs = sor.fields.getMap();
		// Return empty list if field name was not found in the object's field list
		if (!sofs.containsKey(field)) {
			return ples;
		}
		Schema.DescribeFieldResult dfr = sofs.get(field).getDescribe();
		// Return empty list if the field type is not picklist
		if (dfr.getType() != Schema.DisplayType.Picklist) return ples;
		for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
			if (ple.isActive()) {
				ples.add(ple);
			}
		}

		return ples;
	}

	/*
	* @description
	*	Method that converts string to datetime yyyy-mm-dd
	* @params
	*	N/A
	* @return
	*	DateTime
	*/
	public static DateTime strToDateTime(String dStr, Boolean endOfDay) {
		datetime result = null;
		if (String.isNotBlank(dStr)) {
			List<String> p = dStr.split('-');
			result= datetime.newInstanceGMT(Integer.valueOf(p[0]),
			Integer.valueOf(p[1]),
			Integer.valueOf(p[2]),0,0,0);
			if (endOfDay) {
				result = result.addHours(23).addMinutes(59);
			}
		}

		return result;
	}
}