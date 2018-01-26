/**
 * @author Altimetrik
 * @description
 *	started on MM/DD/YYYY
 *	REPLACE_BY_CLASS_LOGIC_RESPONSABILITIES
 **/
public with sharing class aqi_KnowledgeSearchCtrl {
	// Constants
	public static String PUBLISH_STATUS = System.Test.isRunningTest() ? 'Draft' : 'Online';
    public static String DATA_CATEGORY_OPERATOR = ' BELOW ';
    public static String DEFAULT_SITE_NAME = Site.getName();
    public static Id NETWORK_ID = (Network.getNetworkId() != null) ? Network.getNetworkId() : UserInfo.getOrganizationId();
    public final static String DEFAULT_LANGUAGE = aqi_SettingsHandler.customOrDefaultLanguage();
    public final static Integer QUERY_LIMIT = 5000;
    public static String knowledgeObject = aqi_securityHandler.knowledgeObject;

	//************************************************************************
	// Properties & data members

	public List<List<SObject>> articlesQueried {get; set;}
    public List<SObject> articles {get; set;}

    private String sosl {get; set;}
    public String recordTypes {get; set;}
    private String allowedRecordTypes {get; set;}
    public Map<String,Boolean> aqiPerKav {get; set;}
    public String kavId {get; set;}

    public String subject {get; set;}
    public String author {get; set;}
    public String anumber {get; set;}
    public String lastpublisher {get; set;}
    public String dateLastModifiedFrom {get; set;}
    public String dateLastModifiedTO {get; set;}
    public String dateFirstPublishedFrom {get; set;}
    public String dateFirstPublishedTo {get; set;}

    public String sortBy {get; set;}
    public Boolean sortAsc {get; set;}

    public Boolean isValidationStatusActive {get; set;}
    public Boolean isMasterLanguage {get; set;}
    public String tableColumnsWidth {get; set;}

    public Boolean defaultSearch {get; set;}

	/*
	* @description
	*    Returns Boolean value indicating if custom setting record was properly created
	* @return Boolean
	*/
	public static Boolean appConfigured {
		get{
			if (appConfigured == null) {
				appConfigured = ArticleQuality_index__c.getInstance('default') != null;
			}
			return appConfigured;
		}
		private set;
	}
	/*
	* @description
	*    Returns list of available languages
	* @return map<String,String>
	*/
	public static map<String,String> allLanguageOptions{
		get{
			if (allLanguageOptions == null) {
				set<String> availableLanguages = new set<String>();
				if (  String.isNotBlank( ArticleQuality_index__c.getInstance('default').Selected_Languages__c)  ) {
					availableLanguages.addAll(ArticleQuality_index__c.getInstance('default').Selected_Languages__c.split(','));
				}else{
					availableLanguages.add(DEFAULT_LANGUAGE);
				}
				Map<String,String> optionsMap = getActivePicklistOptions('User', 'LanguageLocaleKey');
				allLanguageOptions = new map<String,String>();
				for (String s : availableLanguages) {
					s=s.trim();
					if (optionsMap.containsKey(s))
					allLanguageOptions.put(s, optionsMap.get(s));
				}
			}
			return allLanguageOptions;
		}
		private set;
	}

	public String aLanguage {
		get{
			if ( ! String.isNotBlank(aLanguage) ){
				ArticleQuality_index__c cSettings = ArticleQuality_index__c.getInstance('default');
				if (cSettings != null && String.IsNotBlank(cSettings.Selected_Languages__c) ){
					aLanguage = cSettings.Selected_Languages__c.split(',').get(0);
				}else
					aLanguage = DEFAULT_LANGUAGE;
				}
	            return aLanguage;
			}
			set;
		}
	    public ApexPages.StandardSetController setCon {
	        get{
	            String qString='';
	            if(setCon == null){
	                try{
	                    aqi_SecurityHandler.canAccess(KnowledgeArticleVersion.sObjectType);
	                    aqi_SecurityHandler.canAccess(Article_Quality__c.sObjectType);
	                    aqi_SecurityHandler.canAccess(KnowledgeArticleViewStat.sObjectType);
	                    if (defaultSearch){
	                        System.debug('\n======[DEBUG] setCon calls queryDefaultArticles' );
	                        qString = queryDefaultArticles();
	                    }
	                    else{
	                        System.debug('\n======[DEBUG] setCon calls resolveArticleSearch' );
	                        qString = resolveArticleSearch();
	                    }
	                }catch(Exception e){
	                    ApexPages.addMessage(new ApexPages.Message(
	                    ApexPages.Severity.ERROR,
	                    e.getMessage()
	                    ));
	                }
	                system.debug('\n======*************** queryString :'+qString  );
	                if(String.isNotBlank(qString)){
	                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(qString));
	                    if (setCon.getResultSize() == 0){
	                        if(defaultSearch){
	                            //get populars
	                            qString = queryPopularArticles();
	                            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(qString));
	                        }else{
	                            setCon = new ApexPages.StandardSetController(new List<KnowledgeArticleVersion>());
	                        }
	                    }
	                    setCon.setPageSize(10);
	                }else{
	                    setCon = new ApexPages.StandardSetController(new List<KnowledgeArticleVersion>());
	                }
	                }else{
	                     System.debug('\n======[DEBUG] setCon NOT NULL defaultSearch : '+defaultSearch);
	                }
	            return setCon;
	        }set;
		}
	//************************************************************************
	// Methods

	// Wrapper class for articles
    public class ArticleWrapper {
        public Id articleId {get; set;}
        public Id articleKnowledgeArticleId {get; set;}
        public String articleUrlName {get; set;}
        public String articleCreatedby {get; set;}
        public String articleLastModifiedBy {get; set;}
        public String articleLanguage {get; set;}
        public String articleArticleNumber {get; set;}
        public String articleRecordType {get; set;}
        public String articleTitle {get; set;}
        public String articleSummary {get; set;}
        public String articleValidationStatus {get; set;}
        public Integer articleVersionNumber {get; set;}
        public DateTime articleCreatedDate {get; set;}
        public DateTime articleFirstPublishedDate {get; set;}
        public DateTime articleLastPublishedDate {get; set;}
        public DateTime articleLastModifiedDate {get; set;}

        public ArticleWrapper(KnowledgeArticleVersion kaV, sObject obj, String recordType, Boolean validationStatus) {
            articleId = kaV.Id;
            articleKnowledgeArticleId = kaV.KnowledgeArticleId;
            articleUrlName = kaV.UrlName;
            articleCreatedby = kaV.CreatedBy.Name;
            articleLastModifiedBy = kaV.LastModifiedBy.Name;
            articleLanguage = kaV.Language;
            articleArticleNumber = kaV.ArticleNumber;
            articleRecordType = recordType;
            articleTitle = kaV.Title;
            articleSummary = kaV.Summary;
            articleVersionNumber = kaV.VersionNumber;
            articleCreatedDate = kaV.CreatedDate;
            articleFirstPublishedDate = kaV.FirstPublishedDate;
            articleLastPublishedDate = kaV.LastPublishedDate;
            articleLastModifiedDate = kaV.LastModifiedDate;

            if (validationStatus)
                articleValidationStatus = (String) obj.get('ValidationStatus');
        }
    }

	/*
	* @description
	*	Constructor
	* @params
	*	N/A
	* @return
	*	N/A
	*/
	public aqi_KnowledgeSearchCtrl() {

        sortBy ='Title';
        sortAsc = false;
        defaultSearch = true;
        isValidationStatusActive = checkForSchemaFieldActive('validationstatus');
        isMasterLanguage = checkForSchemaFieldActive('ismasterlanguage');
        allowedRecordTypes = aqi_SecurityHandler.getAllowedRecordTypes();
        if(isValidationStatusActive){
            tableColumnsWidth = '5%, 15%, 7%, 10%, 3%, 30%, 5%, 5%, 5%, 7%, 7%, 1%';
        }else{
            tableColumnsWidth = '5%, 15%, 7%, 10%, 3%, 35%, 5%, 5%, 7%, 7%, 1%';
        }

    }

	/*
	* @description
	*	Method that generate the query string regarding the filters
	* @params
	*	N/A
	* @return
	*	String
	*/
    public String resolveArticleSearch(){
        String artFilter = recordTypeFilters();
        String knowledgeQuery = 'SELECT KnowledgeArticleId FROM ' + knowledgeObject + ' WHERE PublishStatus = \'Online\' AND Language =\'' + escapeString(aLanguage) + '\' AND ' + artFilter;
        System.debug('knowledgeQuery: ' + knowledgeQuery);
        List<sObject> sObjList = Database.query(knowledgeQuery);
        Set<String> knowledgeArticles = new Set<String>();
        for (sObject obj : sObjList) {
            String currentKnowledgeArticle = (String) obj.get('KnowledgeArticleId');
            knowledgeArticles.add(currentKnowledgeArticle);
        }
        System.debug('sObjList: ' + sObjList);
        System.debug('knowledgeArticles: ' + knowledgeArticles);
        String soqlRecFilters = '';
        String soslRecFilters = '';
        if (knowledgeArticles.size() > 0) {
            List<String> theIds = new List<String>();
            for (String aNumber : knowledgeArticles)
                theIds.add(aNumber);
            soslRecFilters = ' AND KnowledgeArticleId IN (\'' + String.join(theIds, '\' ,\'') + '\') ';
            soqlRecFilters = ' AND KnowledgeArticleId IN (\'' + String.join(theIds, '\' ,\'') + '\') ';
        }
        String fieldsToRetrieve = ' Id, UrlName, createdby.name, lastmodifiedby.name, Language, ArticleNumber, VersionNumber, KnowledgeArticleId,  '+
                                  ' Title, CreatedDate, FirstPublishedDate , LastPublishedDate, LastModifiedDate, Summary ';
        if (isValidationStatusActive)
                    fieldsToRetrieve += ',ValidationStatus ';
        //where part
        List<String> whereConditions = new list<String>();
        if (isMasterLanguage)
            whereConditions.add(' IsMasterLanguage = true ');
        whereConditions.add(' PublishStatus=\''+ PUBLISH_STATUS +'\'');
        whereConditions.add(' language =\'' + escapeString(aLanguage) + '\' ');
        if (String.isNotBlank(author))
             whereConditions.add(' createdby.name LIKE \'%' + escapeString(author) + '%\' ');
        if (String.isNotBlank(lastpublisher))
             whereConditions.add(' lastmodifiedby.name LIKE \'%' + escapeString(lastpublisher) + '%\' ');
        if (String.isNotBlank(anumber))
             whereConditions.add(' articlenumber LIKE \'%' + escapeString(anumber) + '%\' ');
        //validate LAST MODIFIED  RANGE
        String aux;
        DateTime auxdt;
        datetime auxDTT_from = strToDateTime(escapeString(dateLastModifiedFrom),false);
        datetime auxDTT_to = strToDateTime(escapeString(dateLastModifiedTo),true);
        if (auxDTT_from != null && auxDTT_to!= null){
            if (auxDTT_from > auxDTT_to) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                        'Last Modified Date range is invalid'));
                return '';
            }
        }
        if ( auxDTT_from != null ){
            aux = auxDTT_from.formatGMT('yyyy-MM-dd') + 'T' + auxDTT_from.formatGMT('HH:mm:ss.SSS') + 'Z';
            whereConditions.add('  LastModifiedDate >=  ' +   aux   );
        }
        if (auxDTT_to != null ){
            aux = auxDTT_to.formatGMT('yyyy-MM-dd') + 'T' + auxDTT_to.formatGMT('HH:mm:ss.SSS') + 'Z';
            whereConditions.add('  LastModifiedDate <=  ' + aux   );
        }
        //validate CREATED DATE RANGE
        auxDTT_from = strToDateTime(escapeString(dateFirstPublishedFrom),false);
        auxDTT_to = strToDateTime(escapeString(dateFirstPublishedTo),true);
        if (auxDTT_from != null && auxDTT_to!= null){
            if (auxDTT_from > auxDTT_to) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                        'Created Date range is invalid'));
                return '' ;
            }
        }
        if (auxDTT_from != null ){
            aux = auxDTT_from.formatGMT('yyyy-MM-dd') + 'T' + auxDTT_from.formatGMT('HH:mm:ss.SSS') + 'Z';
            whereConditions.add('  FirstPublishedDate >=  ' +  aux  );
        }
        if (auxDTT_to != null ){
            aux = auxDTT_to.formatGMT('yyyy-MM-dd') + 'T' + auxDTT_to.formatGMT('HH:mm:ss.SSS') + 'Z';
            whereConditions.add('  FirstPublishedDate <=  ' +  aux   );
        }
        String whereClause =' WHERE  ' + String.join(whereConditions,' AND ');
        String orderByClause =    '   ORDER BY '+String.escapeSingleQuotes(sortBy)  ;
                orderByClause +=    sortAsc ? ' ASC ' : ' DESC '  ;
        String queryString='';
        if(String.isNotBlank(anumber) &&  !anumber.isNumeric()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                                'Article Number must contain only numbers'));
                        return '';
        }
        if (    String.isNotBlank(subject)  ){
            if(subject.length()< 2){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                                                    'Search criteria must be at least two characters '));
                            return '';
            }
            String scapedSubject = escapeReservedChars(subject);
            if(scapedSubject.length()< 2){
                articles = new List<SObject>();
                return '';
            }
            /* SOSL QUERY */
            queryString =   ' FIND \''+  scapedSubject  +'*\' IN ALL FIELDS RETURNING '+
                            ' KnowledgeArticleVersion ' +
                            ' (Id ' + whereClause + soqlRecFilters + ')';
            articlesQueried = search.query(queryString);
            articles = ((List<Sobject>)articlesQueried[0]);
            List<String> lIds = new List<String>();
            if(!articles.isEmpty()){
                //Creating set of ids
                for(SObject sObj : articles){
                    lIds.add(((KnowledgeArticleVersion)sObj).Id);
                }
            }
            String idString = ' (\''+String.join(lIds,'\',\'')+'\') ';
            queryString =   ' SELECT ' + fieldsToRetrieve +
                            ' FROM KnowledgeArticleVersion ' +
                                ' WHERE Id in  ' + idString +
                                orderByClause +
                            ' LIMIT ' + QUERY_LIMIT;
        }else{
            /* SOQL QUERY */
            queryString =   ' SELECT '+fieldsToRetrieve +
                            ' FROM KnowledgeArticleVersion ' + whereClause +
                            soqlRecFilters + orderByClause +
                            ' LIMIT ' + QUERY_LIMIT;
        }
        return queryString;
    }

	/*
	* @description
	*	Method that generate the default query string
	* @params
	*	N/A
	* @return
	*	String
	*/
   public String queryDefaultArticles(){
        setCon = null;
        map<String,String> aqiIds = new map<String,String>();
        //get knowledge article id's at their latest version already qualified
        for (AggregateResult ar : [ SELECT  Knowledge_Article_Id__c aKId , max(Article_Version__c)
                                    FROM Article_Quality__c
                                    GROUP BY Knowledge_Article_Id__c
                                    LIMIT 1000 ])  {
            aqiIds.put(String.valueOf(ar.get('aKId')),String.valueOf(ar.get('expr0')));
        }
        set<String> theIds = aqiIds.keySet();
        set<String> idToFilter = new set<String>();
        Integer tmpVersionN=0;
        for( KnowledgeArticleVersion ktmp :Database.query(  ' SELECT VersionNumber, KnowledgeArticleId '+
                                                            '  FROM KnowledgeArticleVersion '+
                                                            ' WHERE  '+
                                                            '    PublishStatus=\''+ PUBLISH_STATUS +'\' '+
                                                            '   AND language =\'' + escapeString(aLanguage) + '\''+
                                                            ' LIMIT ' + QUERY_LIMIT)){
			if (aqiIds.containsKey(ktmp.KnowledgeArticleId)){
                tmpVersionN = ktmp.VersionNumber;
                if (tmpVersionN == Integer.valueOf(aqiIds.get(ktmp.KnowledgeArticleId))){
                        idToFilter.add(ktmp.KnowledgeArticleId);
                }
            }
        }
        String queryArticles =  '  SELECT Id, UrlName, createdby.name, lastmodifiedby.name, Language, ArticleNumber, VersionNumber, KnowledgeArticleId,  '+
                                    ' Title, CreatedDate, FirstPublishedDate, LastPublishedDate, LastModifiedDate, Summary ';
        if (isValidationStatusActive)
			queryArticles += ', ValidationStatus ';
        queryArticles +=  '     FROM KnowledgeArticleVersion '+
                            '   WHERE PublishStatus=\''+ PUBLISH_STATUS +'\' AND language =\'' + escapeString(aLanguage) + '\' '+
                            '   ';
        if (isMasterLanguage)
            queryArticles += '   AND IsMasterLanguage = true ';
        // queryArticles +=    recordTypeFilters() ;
        queryArticles +=    '   ORDER BY '+String.escapeSingleQuotes(sortBy)  ;
        queryArticles +=    sortAsc ? ' ASC ' : ' DESC '  ;
        queryArticles +=    'LIMIT ' + QUERY_LIMIT;
		return queryArticles;
	}


	/*
	* @description
	*	Method that generate the query string for the popular articles
	* @params
	*	N/A
	* @return
	*	String
	*/
    public String queryPopularArticles(){
        setCon = null;

        String queryArticles;
        String artFilter = recordTypeFilters();

        String queryStats = ' SELECT Id,NormalizedScore,ParentId '+
                            ' FROM KnowledgeArticleViewStat '+
                            ' WHERE Channel = \'AllChannels\' '+
                            ' ORDER BY NormalizedScore DESC LIMIT 5';
        list<String> theIds = new list<String>();
        list<SObject> theviews = new list<SObject>();
        theviews = Database.query(queryStats);


        for( SObject theview : theviews){
            theIds.add(String.valueOf(theview.get('ParentId')));

        }

        String idString = ' (\''+String.join(theIds,'\',\'')+'\') ';

        queryArticles =  '  SELECT Id, UrlName, createdby.name, lastmodifiedby.name, Language, ArticleNumber, VersionNumber, KnowledgeArticleId,  '+
                                    ' Title, CreatedDate, FirstPublishedDate, LastPublishedDate, LastModifiedDate, Summary ';
        if (isValidationStatusActive)
            queryArticles += ', ValidationStatus ';

        queryArticles += ' FROM KnowledgeArticleVersion '+
                            ' where PublishStatus=\''+ PUBLISH_STATUS +'\' AND language =\'' + escapeString(aLanguage) + '\' '+
                            ' AND KnowledgeArticleId IN  '+idString;
         if (isMasterLanguage)
            queryArticles += '  AND IsMasterLanguage = true ';

        // queryArticles +=    artFilter ;
        queryArticles +=    '   ORDER BY '+String.escapeSingleQuotes(sortBy)  ;
        queryArticles +=    sortAsc ? ' ASC ' : ' DESC '  ;
        queryArticles +=    'LIMIT ' + QUERY_LIMIT;

        return queryArticles;

    }

	/*
	* @description
	*	Method that make an update in the sort
	* @params
	*	N/A
	* @return
	*	PageReference
	*/
    public PageReference updateSort(){

        sortAsc = !sortAsc;
        if (!defaultSearch)
            runSearch();
        else{
            this.setCon = null;
            defaultSearch = true;
            getMyArticles();
        }
        return null;
    }

	/*
	* @description
	*	Method that gets parameters from page to build the query for KnolwedgeArticles
	* @params
	*	N/A
	* @return
	*	PageReference
	*/
    public PageReference runSearch() {

        this.setCon = null;
        defaultSearch = false;
        getMyArticles();
        this.setCon.setPageNumber(1);

        return null;
    }

	/*
	* @description
	*	Method that gets List of ArticleWrapper
	* @params
	*	N/A
	* @return
	*	List<ArticleWrapper>
	*/
    public List<ArticleWrapper> getMyArticles() {
        List<ArticleWrapper> articlesList = new List<ArticleWrapper>();
        try {
            Set<id> kavIds = new Set<id>();
            Set<decimal> kavVers = new Set<decimal>();
            for (SObject sObj : (List<SObject>)setCon.getRecords()) {
                kavIds.add(((KnowledgeArticleVersion)sObj).KnowledgeArticleId);
                kavVers.add(((KnowledgeArticleVersion)sObj).VersionNumber);
            }
            List<Id> kavIdsString = new List<Id>();
            kavIdsString.addAll(kavIds);
            String knowledgeQuery = 'SELECT Id, KnowledgeArticleId, RecordTypeId FROM ' + knowledgeObject +
                                    ' WHERE PublishStatus = \'Online\' AND Language =\'' + escapeString(aLanguage) + '\' AND KnowledgeArticleId IN (\'' + String.join(kavIdsString, '\' ,\'') + '\')';
            List<sObject> sObjList = Database.query(knowledgeQuery);
            Map<Id,Id> knowledgeIdToRecordType = new Map<Id,Id>();
            for (sObject obj : sObjList) {
                Id recordTypeId = (Id) obj.get('RecordTypeId');
                knowledgeIdToRecordType.put((Id) obj.get('KnowledgeArticleId'), recordTypeId);
            }
            for (SObject sObj : (List<SObject>)setCon.getRecords()) {
                Map<Id,String> rtIdsToMap = aqi_SecurityHandler.getAllowedRecordTypesMap();
                Id knowId = (Id) sObj.get('KnowledgeArticleId');
                KnowledgeArticleVersion kaV = (KnowledgeArticleVersion) sObj;
                articlesList.add(new ArticleWrapper(kaV, sObj, rtIdsToMap.get(knowledgeIdToRecordType.get(knowId)), isValidationStatusActive));
            }
            if ( !kavIds.isEmpty() )
               populateAqi(kavIds, kavVers);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() +'\n'+ e.getStackTraceString()));
        }
        return articlesList;
    }

	/*
	* @description
	*	Method that populateAqi map - set the knowledge article id to true in the map if exist on the results of the query
	* @params
	*	Set of Ids, Set of Decimal
	* @return
	*	N/A
	*/
    private void populateAqi(set<Id> idSet, set<Decimal> verSet){
        aqiPerKav = new Map<String,Boolean>();
        for(id i : idSet){
            aqiPerKav.put(i,false);
        }
        List<Article_Quality__c> aqis = [ SELECT Id, Knowledge_Article_Id__c, Language__c, Article_Version__c
                                          FROM Article_Quality__c
                                          WHERE Knowledge_Article_Id__c in: idSet
                                          AND Language__c =: aLanguage
                                          AND Article_Version__c in: verSet
                                          LIMIT :QUERY_LIMIT ];

        Map<String,Article_Quality__c> mapAqi = new Map<String, Article_Quality__c>();
        for(Article_Quality__c aqi : aqis){
            mapAqi.put(aqi.Knowledge_Article_Id__c + aqi.Language__c + aqi.Article_Version__c, aqi);
        }
        for(SObject sObj : (List<SObject>)setCon.getRecords()){
            KnowledgeArticleVersion maqi = (KnowledgeArticleVersion)sObj;
            if(mapAqi.containsKey(maqi.KnowledgeArticleId + maqi.Language + maqi.VersionNumber)){
                aqiPerKav.put(maqi.KnowledgeArticleId, true);
            }
        }
    }

	/*
	* @description
	*	Check if we have next page
	*/
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }

	/*
	* @description
	*	Check if we have previous page
	*/
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }

	/*
	* @description
	*	Check the page number
	*/
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }

	/*
	* @description
	*	Check the result size
	*/
    public Integer resultSize {
        get {
            return setCon.getResultSize();
        }
        set;
    }

	/*
	* @description
	*	Check the page size
	*/
    public Integer pageSize {
        get {
            return setCon.getPageSize();
        }
        set;
    }

	/*
	* @description
	*	Set the page at first
	*/
    public void first() {
        setCon.first();
    }

	/*
	* @description
	*	Set the page at last
	*/
    public void last() {
        setCon.last();
    }

	/*
	* @description
	*	Set the page at previous
	*/
    public void previous() {
        setCon.previous();
    }

	/*
	* @description
	*	Set the page at next
	*/
    public void next() {
        setCon.next();
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

        // return empty list if object name was not found in the schema
        if (!gd.containsKey(so)) return ples;

        Schema.DescribeSObjectResult sor = gd.get(so).getDescribe();
        Map<String,Schema.SObjectField> sofs = sor.fields.getMap();

        // return empty list if field name was not found in the object's field list
        if (!sofs.containsKey(field)) return ples;

        Schema.DescribeFieldResult dfr = sofs.get(field).getDescribe();

        // return empty list if the field type is not picklist
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
	*	Method that return a String with the record type filters
	* @params
	*	N/A
	* @return
	*	String
	*/
    public String recordTypeFilters() {
        String typesFilter = '';
        if (String.isNotBlank(recordTypes) && (recordTypes != 'All')) {
            recordTypes = String.escapeSingleQuotes(recordTypes);
            List<String> lStr = recordTypes.split(',');
            List<String> lIds = new List<String>();
            Map<Id,String> rtIdsToMap = aqi_SecurityHandler.getAllowedRecordTypesMap();
            for (Id currentFilter : lStr) {
                if (rtIdsToMap.containsKey(currentFilter))
                    lIds.add(currentFilter  );
            }
            typesFilter = ' RecordTypeId IN (\'' + String.join(lIds, '\' ,\'') + '\')';
        }
        else {
            List<String> lStr = allowedRecordTypes.split(',');
            List<Id> lIds = new List<Id>();
            Map<String,Id> rtNameToIds = aqi_SecurityHandler.getAllowedRecordTypeNameToIdMap();
            for (String currentFilter : lStr) {
                String finalFilter = currentFilter.remove('\'');
                if (rtNameToIds.containsKey(finalFilter))
                    lIds.add(rtNameToIds.get(finalFilter));
            }
            typesFilter = ' RecordTypeId IN (\'' + String.join(lIds, '\' ,\'') + '\')';
        }
        return typesFilter;
    }

	/*
	* @description
	*	Method that return a List of selectOptions for the languages
	* @params
	*	N/A
	* @return
	*	List<SelectOption>
	*/
    public List<SelectOption> getLanguageOptions() {
        List<SelectOption> options = new List<SelectOption>();
        ArticleQuality_index__c aqs = ArticleQuality_index__c.getInstance('default');
        if (aqs != null){
            set<String> availableLanguages = new set<String>();
            if (  String.isNotBlank( ArticleQuality_index__c.getInstance('default').Selected_Languages__c)  ) {
                availableLanguages.addAll(ArticleQuality_index__c.getInstance('default').Selected_Languages__c.split(','));
            }else{
                availableLanguages.add(DEFAULT_LANGUAGE);
            }
            Map<String,String> optionsMap = getActivePicklistOptions('User', 'LanguageLocaleKey');
            allLanguageOptions = new map<String,String>();
            for (String s : availableLanguages) {
                s=s.trim();
                if (optionsMap.containsKey(s))
                    options.add(new SelectOption(s, optionsMap.get(s)));
            }
        }
        return options;
    }

	/*
	* @description
	*	Method that return a List of selectOptions for the allowed record types
	* @params
	*	N/A
	* @return
	*	List<SelectOption>
	*/
    public List<SelectOption> getTheRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        Map<Id, String> rts = aqi_securityHandler.getAllowedRecordTypesMap();
        options.add(new SelectOption('', 'All'));
        for (Id key : rts.keySet()) {
            options.add(new SelectOption(key, rts.get(key)));
        }
        return options;
    }

	/*
	* @description
	*	Method that return a boolean to know if the fieldname exist on the fields of the schema
	* @params
	*	N/A
	* @return
	*	Boolean
	*/
    public boolean checkForSchemaFieldActive(String fieldName){
        Set<String> objectFields = Schema.SObjectType.KnowledgeArticleVersion.fields.getMap().keySet();
        return objectFields.contains(fieldName);
    }

	/*
	* @description
	*	Method that escape the string
	* @params
	*	N/A
	* @return
	*	String
	*/
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
	*	Method that convert string to datetime
	* @params
	*	N/A
	* @return
	*	DateTime
	*/
    private DateTime strToDateTime(String dStr, Boolean endOfDay){
        datetime result = null;
        if (String.isNotBlank(dStr)){
            list<String> p = dStr.split('/');

            result= datetime.newInstanceGMT(   Integer.valueOf(p[2]),
                                            Integer.valueOf(p[0]),
                                            Integer.valueOf(p[1]),0,0,0 );

            if (endOfDay)
                result = result.addHours(23).addMinutes(59);
        }
       return result;
    }

	/*
	* @description
	*	Method that escape reserved chars
	* @params
	*	N/A
	* @return
	*	String
	*/
    private String escapeReservedChars(String str){

        String result = null;
        Pattern p = Pattern.compile('([-&\\|!\\(\\){}\\[\\]\\^\"\'\\~\\+\\-\\?:\\\\])');

        if (String.isNotBlank(str)){
            result = p.matcher(str.trim()).replaceAll('');
        }else{
            result ='';
        }

        return escapeString(result);

    }

}
