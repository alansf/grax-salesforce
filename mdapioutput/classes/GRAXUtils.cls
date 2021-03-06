/*****************************************************************************************
Name              : GRAXUtils
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       07/03/2018             
******************************************************************************************/
public with sharing class GRAXUtils {
    private static Map<String, Schema.SObjectType> globalDescribe;
    private static Map<String, Schema.DescribeSObjectResult> objectsFullDescribe {get; set;}
    private static Map<String, Map<String, Schema.DescribeFieldResult>> fieldsDescribeByObject;

    public static Boolean sObjectExists( String objName ){
        if(globalDescribe == null){ 
        	globalDescribe = Schema.getGlobalDescribe();
        }
        
        return globalDescribe.containsKey( objName );
    }

    private static void loadObjectAndFieldsDescribe(String objName){
        if(fieldsDescribeByObject == null){ 
            globalDescribe                          = Schema.getGlobalDescribe();
            objectsFullDescribe                     = new Map<String, Schema.DescribeSObjectResult>();
            fieldsDescribeByObject                  = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        }
        
        if(!fieldsDescribeByObject.containsKey(objName) && sObjectExists(objName) ){
            Schema.DescribeSObjectResult objDesc = globalDescribe.get(objName).getDescribe();
            objectsFullDescribe.put(objDesc.getName(), objDesc);
            Map<String, Schema.DescribeFieldResult> fieldsDescribe = new Map<String, Schema.DescribeFieldResult>();
            
            // Get the describe of each field of the object
            for(Schema.SObjectField sField: objDesc.fields.getMap().values()){
                Schema.DescribeFieldResult fldDescRes = sField.getDescribe();
                fieldsDescribe.put(fldDescRes.getName(), fldDescRes);                    
            }
            fieldsDescribeByObject.put(objDesc.getName(), fieldsDescribe);
        } 
    }

    public static Schema.DescribeSObjectResult getObjectDescribe(String objName){
    	loadObjectAndFieldsDescribe(objName);
    	
    	return objectsFullDescribe.get(objName);
    }

    public static Map<String, Schema.DescribeFieldResult> getDescribeFieldsResultForObject(String objName){
    	loadObjectAndFieldsDescribe(objName);
    	
    	return fieldsDescribeByObject.get(objName);
    }

    public static Schema.DescribeFieldResult getFieldDescribeFromSObjectField(Schema.SObjectField sObjFld){
        return sObjFld.getDescribe();
    }

    public static Schema.DescribeFieldResult getNameFieldDescForObject(String objName){    	    	
    	Schema.DescribeFieldResult result;
        
        if( sObjectExists(objName) ){
            // Get the Name field defined for each object
            for(Schema.DescribeFieldResult fieldDesc : getDescribeFieldsResultForObject(objName).values()){
                if(fieldDesc.isNameField()){
                    result = fieldDesc;
                    break;
                }
            }
        }
        
    	return result;
    }   

    public static String getObjectNameFromSObjectType(Schema.SObjectType sObjT){
        String objName = '';
        
        if(globalDescribe == null){ 
        	globalDescribe = Schema.getGlobalDescribe();
        }
        	
        for(Schema.SObjectType objSObjType : globalDescribe.values()){
        	if(sObjT == objSObjType){
        		objName = sObjT.getDescribe().getName();
        		break;
        	}
        }
        
        return objName;
    }

    public static SObject createObjectInstance(String objName){
    	if(globalDescribe == null){ 
        	globalDescribe = Schema.getGlobalDescribe();
        }
    	
    	SObject result = globalDescribe.get(objName).newSObject(null, true);
    	
    	return result;
    }

    public static String CleanFieldLabel(Schema.DescribeFieldResult sField, Boolean escapeForVF){
        String fieldLabel = sField.getLabel();
       	
       	if(!sField.isCustom() && sField.getType().name() == 'REFERENCE' && fieldLabel.endsWith(' ID')){
       		fieldLabel = fieldLabel.removeEnd(' ID');
       	} 
		
		if(escapeForVF){
			fieldLabel = fieldLabel.escapeHtml4();
		}
		
        return fieldLabel;
    }


    public static List<String> getReferenceFields(String objName) {
        loadObjectAndFieldsDescribe(objName);

        List<String> referenceFields = new List<String>();
        List<String> excludedFields = new List<String>();
        //String nameField = getNameFieldDescForObject(objName).getName();

        Map<String, Schema.DescribeFieldResult> fieldsDesc = fieldsDescribeByObject.get(objName);

        for(String fieldName : fieldsDesc.keySet()) {
            
            Schema.DescribeFieldResult fieldDesc = fieldsDesc.get(fieldName);
            
            // Check if this field is accessible for the current User
            if(fieldDesc <> null){
                
                // If the current field is a reference field, get the Name field of the related object to be used in the search
                if(fieldDesc.getType().name().equalsIgnoreCase('REFERENCE')){

                    String nameField = 'Name';

                    if(fieldDesc.getReferenceTo().size() == 1) {
                        nameField = '';
			    
                        // Get the Name field defined for this related object
                        String relObjName = getObjectNameFromSObjectType(fieldDesc.getReferenceTo()[0]);
                        Schema.DescribeSObjectResult relObjDescribe = getObjectDescribe(relObjName);
			    
                        // Get the Name field of the related object
                        Schema.DescribeFieldResult relNameFieldDesc = getNameFieldDescForObject(relObjName);
			    
                        if(relObjDescribe <> null && relNameFieldDesc<>null){    
                            nameField = relNameFieldDesc.getName();
                        }
                    }

                    String relationName = fieldDesc.getRelationshipName();

                    if(String.isNotBlank(relationName) && nameField <> '') {
                        referenceFields.add(relationName + '.' + nameField);
                    }
                }
                
            }
        }

        return referenceFields;
    }

    public static Object parseSObjectFieldValue(SObject sobj, String refField){
        Object fieldValue;

        // Split the field by '.' and traverse the object relationship
        List<String> objFields = refField.split('\\.');
        SObject dynObj = sobj;
        for(Integer i = 0; i < objFields.size() - 1; i++){
            if(dynObj <> null){
                dynObj = dynObj.getSObject(objFields[i]);
            }
        }
        
        // Get the Field Name to retrieve
        String relatedObjField = objFields[objFields.size()-1];
        
        // Retrieve the value of the field
        if(dynObj <> null){
            fieldValue = dynObj.get(relatedObjField);
        }
		
        return fieldValue;
    }

    // Description: Cast the value passing by parameter to the specified Field Type. 
    public static Object castGenericObjectToType(Object objValue, String fieldType){ 
    	Object result = objValue;
        
        if(objValue <> null){
        	String obj = String.valueOf(objValue);
            
            if(String.isBlank(obj)){
                result = null;
            }else{
                if((new Set<String>{'time', 'datetime', 'date'}).contains(fieldType.toLowerCase())){
	                if(fieldType.equalsIgnoreCase('time')){
	                	// The assumption is that TIME values will be in this format '16:45:47.000Z'
	                	// Add the time portion to it, so it is treated as a Datetime
	                	obj = '2000-01-01T' + obj;
	                }
	                
	                if( obj.length() > 19 && obj.contains('T')){
                        //Bad format 2016-07-29T16:45:47.000Z . Reformat to 2016-07-29 16:45:47
                        obj = obj.replace('T', ' ').subString(0, 19);
                    }
                    
                    if(fieldType.equalsIgnoreCase('datetime') || fieldType.equalsIgnoreCase('time')){
	                    if( obj.contains('/') ){
	                        //MONTH/DAY/YEAR
	                        result = (Object)Datetime.parse(obj);
	                    }else{
	                        //YEAR-MONTH-DAY
	                        result = (Object)Datetime.valueOfGMT(obj);
	                    }
	                }else if(fieldType.equalsIgnoreCase('date')){
	                    if( obj.contains('/') ){
	                        //MONTH/DAY/YEAR
	                        result = (Object)Date.parse(obj);
	                    }else{
	                        //YEAR-MONTH-DAY
	                        result = (Object)Date.valueOf(obj);
	                    }
	                }
	                
	                if(fieldType.equalsIgnoreCase('time')){
	                	// This value was already transformed to a Datetime, extract the Time portion of it
	                	result = (Object)(((Datetime)result).timeGMT());
	                }
                }else if(fieldType.equalsIgnoreCase('boolean')){
                    result = (Object)Boolean.valueOf(obj);
                }else if(fieldType.equalsIgnoreCase('integer')){
                    result = (Object)Integer.valueOf(obj);
                }else if(fieldType.equalsIgnoreCase('double') || fieldType.equalsIgnoreCase('currency') || fieldType.equalsIgnoreCase('percent')){
                    result = (Object)Double.valueOf(obj);
                }else if(fieldType.equalsIgnoreCase('decimal')){
                    result = (Object)Decimal.valueOf(obj);
                }else{                      
                    result = obj;
                }
            }
        }
               
        return result;
    }

    private static GRAXSettings__c gs;

    public static GRAXSettings__c getGRAXSettings() {
        if(gs == null) {
            gs = GRAXSettings__c.getOrgDefaults();
        }

        return gs;
    }

    public static void setBatchMaxExecutionNumber(Integer newValue) {
        gs.BatchMaxExecutionNumber__c = newValue;

        upsert gs;
    }

    public static Integer getBatchMaxExecutionNumber() {
        return 2000;
    }

    public static Decimal getObjectMaxTotalBytes(String sobjectName) {
        Map<String, Schema.DescribeFieldResult> fieldsMap = getDescribeFieldsResultForObject(sobjectName);

        Decimal totalBytes = 0;

        for(Schema.DescribeFieldResult dfr: fieldsMap.values()) {
            if(!dfr.getType().name().equalsIgnoreCase('base64')){
                totalBytes += dfr.getByteLength();
            }
        }

        return Math.ceil(totalBytes * 0.1);
    }

    public static Integer getBatchMaxExecutionNumber(String sobjectName) {
        List<Integer> batchExecutionSizeList = new List<Integer>{1, 2, 5, 10, 20, 25, 50, 100, 200, 400, 500, 1000, 2000};
        Integer maxBytes = 8388608;
        Integer maxExecutionNumber = 2000; 
        Integer executionNumber = maxExecutionNumber;

        Decimal totalBytes = getObjectMaxTotalBytes(sobjectName);

        executionNumber = (Integer)Math.ceil(maxBytes / totalBytes);
        executionNumber = Math.min(executionNumber, maxExecutionNumber);
		
        // Iterate through the list of possible batch execution sizes and return the closest value less than the estimated
        for(Integer i = 1; i < batchExecutionSizeList.size(); i++){
            if(executionNumber < batchExecutionSizeList[i]){
                executionNumber = batchExecutionSizeList[i-1];
                break;
            }
        }
        
        return executionNumber;
    }

    public static void setSelectionJSON(Id gspId, String jsonContent) {
        setSelectionJSON(new Attachment(
            ParentId = gspId,
            Name = 'SelectionJSON.txt'
        ), jsonContent);
    }

    public static void setSelectionJSON(Attachment att, String jsonContent) {
        if(att <> null) {
            att.Body = Blob.valueOf(jsonContent);
            
            upsert att;
        }
    }

    public static String getSelectionJSON(Id gspId) {
        return getSelectionJSON(getSelectionAttachment(gspId));
    }

    public static String getSelectionJSON(Attachment att) {
        String retJSON = '{}';

        if(att <> null) {
            try {
                retJSON = att.Body.toString();
            } catch (Exception e) {
                retJSON = EncodingUtil.base64Encode(att.Body);
            }
        }

        return retJSON;
    }

    public static Attachment getSelectionAttachment(Id gspId) {
        Attachment retAtt;

        for(Attachment att : [SELECT Body FROM Attachment WHERE ParentId = :gspId AND Name = 'SelectionJSON.txt' ORDER BY Id DESC LIMIT 1]) {
            retAtt = att;
        }

        return retAtt;
    }


    public static Boolean idExist(String sid) {
        try {
            Id recordId = Id.valueOf(sid);
            
            String soql = 'SELECT count() FROM ' + recordId.getSObjectType() + ' WHERE Id = :recordId';
            
            return Database.countQuery(soql) == 1;
        } catch (Exception e) {}

        return false;
    }

    public static Boolean isPersonAccountEnabled() {
        return getDescribeFieldsResultForObject('Account').containsKey('IsPersonAccount');
    }

    public static String getPageParameter(String paramName) {
        String paramValue;

        try {
            paramValue = Apexpages.currentPage().getParameters().get(paramName);
        } catch(Exception e) {}

        return paramValue;
    }

    public static SObject getSObjectById(Id sId) {
        String sObjectName = getSObjectNameById(sId);
        
        return getSObjectById(sId, sObjectName);
    }

    public static SObject getSObjectById(Id sId, String sObjectName) {
        loadObjectAndFieldsDescribe(sObjectName);

        String sObjectFields = String.join(new List<String>(getDescribeFieldsResultForObject(sObjectName).keySet()), ', ');

        return Database.query('SELECT ' + sObjectFields + ' FROM ' + sObjectName + ' WHERE Id = :sId LIMIT 1');
    }

    public static String getSObjectNameById(Id sId) {
        return sId.getSObjectType().getDescribe().getName();
    }

}
