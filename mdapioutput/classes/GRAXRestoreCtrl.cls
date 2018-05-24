/*****************************************************************************************
Name              : GRAXRestoreCtrl
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       05/11/2018             David Mackey        "Restore" Button for Backup/Archive (https://app.asana.com/0/326600806074978/665432711419635/f)
******************************************************************************************/
public with sharing class GRAXRestoreCtrl {
    public GRAXSettings gxcSettings;
    public Id parentId;
    public String parentType;
    public List<String> selectedFieldsList {get;set;}
    public Map<String, SObject> sObjectMap {get;set;}
    public SObject sobjectToRestore {get;set;}
    public Map<String, Schema.SObjectType> globalDescribe {get;set;}
    public Map<String, ChildRelatedItem> childRelatedMap {get;set;}

    public Map<String, Field> fieldMap {get;set;}
    public Set<String> fieldSetToExclude = new Set<String>{'Id', 'IsDeleted', 'SystemModstamp'};

    public List<Object> tableRecords {get;set;}
    public String selectedFields {get;set;}

    public String objToQuery {get;set;}
    public String relToQuery {get;set;}

    public class Field {
        public String name {get;set;}
        public String label {get;set;}
        public String type {get;set;}

        public Boolean isCreateable {get;set;}
        public Boolean isNamePointing {get;set;}

        public String containerClass;
        public String styleClass;

        public Field(Schema.DescribeFieldResult fd) {
            this.name = fd.getName();
            this.label = CleanFieldLabel(fd, true);
            this.type = fd.getType().name();

            this.isCreateable = fd.isCreateable();
            this.isNamePointing = fd.isNamePointing();
        }

        public String getStyleClass() {
            String cls = 'slds-input';

            if(type == 'PICKLIST') {
                cls = 'slds-select';
            }

            if(type == 'TEXTAREA') {
                cls = 'slds-textarea';
            }

            if(type == 'REFERENCE' && isNamePointing) {
                cls = 'is-name-pointing';
            }

            return cls;
        }

        public String getContainerClass() {
            String cls = '';

            if(type == 'PICKLIST') {
                cls = 'slds-select_container';
            }

            if(type == 'REFERENCE') {
                cls = 'slds-input-has-icon slds-input-has-icon_right';
            }

            if(type == 'BOOLEAN') {
                cls = 'slds-checkbox';
            }

            return cls;
        }

        public String CleanFieldLabel(Schema.DescribeFieldResult sField, Boolean escapeForVF){
            String fieldLabel = sField.getLabel();
            
            if(!sField.isCustom() && sField.getType().name() == 'REFERENCE' && fieldLabel.endsWith(' ID')){
                fieldLabel = fieldLabel.removeEnd(' ID');
            } 
            
            if(escapeForVF){
                fieldLabel = fieldLabel.escapeHtml4();
            }
            
            return fieldLabel;
        }
    }

    public GRAXRestoreCtrl() {
        objToQuery = '';

        fieldMap = new Map<String, Field>();
        sObjectMap = new Map<String, SObject>();
        globalDescribe = Schema.getGlobalDescribe();
        tableRecords = new List<Object>();

        String strParentId = Apexpages.currentPage().getParameters().get('Id');
        if(String.isNotBlank(strParentId)) {
            parentId = Id.valueOf(strParentId);
            parentType = parentId.getSObjectType().getDescribe().getName();
        }
    }

    public void retriveTableRecords() {
        tableRecords.clear();

        GRAXSettings gxcSettings = new GRAXSettings(objToQuery);

        String content = '';
        content = '{' +
            '"s3audit":"true",' + 
            '"s3accesskeyid":"' + gxcSettings.graxConfig.s3accesskeyid__c + '",' + 
            '"s3secretaccesskey":"' + gxcSettings.graxConfig.s3secretaccesskey__c + '",' + 
            '"s3region":"' + gxcSettings.graxConfig.s3region__c + '",' + 
            '"orgid": "'+ UserInfo.getOrganizationId() + '",' +
            '"filterfield": "'+ relToQuery + '",' +
            '"filtervalue": "'+ parentId + '",' +
            '"objecttype": "'+ objToQuery + '",' +
            '"fields": "Id,'+ selectedFields + '"' + 
        '}';
        
        System.debug(content);

        String url = gxcSettings.ApiURL + '/audittrail/query';
        GRAXCloud.CallOutResponse callOutRes = GRAXCloud.calloutnow(url, content);

        System.debug(callOutRes);

        if(callOutRes.success) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(callOutRes.response);
            tableRecords = (List<Object>)(responseMap.get('data'));
        }
    }


    public SObject createSObject(String typeName, Map<String, Object> mo) {
        SObject so = globalDescribe.get(typeName).newSObject();

        for(Field f : fieldMap.values()) {
            try {
                if(f.isCreateable) so.put(f.name, castGenericObjectToType(mo.get(f.name), f.type));
            } catch(Exception e) {
                System.debug(LoggingLevel.WARN, e.getMessage() + ' on field ' + f.label);
            }
        }

        return so;
    }


    public void updateSObjectMap() {
        sObjectMap.clear();

        if(String.isNotBlank(objToQuery)) {
            for(Object o : tableRecords) {
                Map<String, Object> mo = (Map<String, Object>)o;
                SObject so = createSObject(objToQuery, mo);

                sObjectMap.put((String)mo.get('Id'), so);
            }
        }
    }

    public void updateSObjectFields(){
        fieldMap.clear();

        if(String.isNotBlank(objToQuery)) {
            // Get a map of field name and field token
            Map<String, Schema.SObjectField> fMap = globalDescribe.get(objToQuery).getDescribe().Fields.getMap();
            
            if(fMap != null){
                for(Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    
                    Field f = new Field(fd);
                    if(!fieldSetToExclude.contains(f.name)) {
                        fieldMap.put(f.name, f);
                    }
                }
            }
        }
    }

    public List<Field> getSObjectFields() {
        return fieldMap.values();
    }

    public Boolean getIsFieldSelected() {
        return String.isNotBlank(selectedFields);
    }

    public Boolean getIsTableRecordsEmpty() {
        return tableRecords.isEmpty();
    }

    public Pagereference changeObjToQuery() {
        String objToQueryIndex = Apexpages.currentPage().getParameters().get('objToQueryValue');
        
        if(String.isNotBlank(objToQueryIndex)) {
            objToQuery = childRelatedMap.get(objToQueryIndex).name;
            relToQuery = childRelatedMap.get(objToQueryIndex).value;

            updateSObjectFields();
        }
        
        return null;
    }

    public Pagereference updateDataTable() {
        selectedFields = Apexpages.currentPage().getParameters().get('selectedFields');
        selectedFieldsList = selectedFields.split(',');

        retriveTableRecords();
        updateSObjectMap();

        return null;
    }

    public Pagereference changeSObjectToRestore() {
        String soToRestore = Apexpages.currentPage().getParameters().get('soToRestore');

        GRAXSettings gxcSettings = new GRAXSettings(objToQuery);

        if(String.isNotBlank(soToRestore)) {
            String content = '';
            content = '{' +
                '"s3audit":"true",' + 
                '"s3accesskeyid":"' + gxcSettings.graxConfig.s3accesskeyid__c + '",' + 
                '"s3secretaccesskey":"' + gxcSettings.graxConfig.s3secretaccesskey__c + '",' + 
                '"s3region":"' + gxcSettings.graxConfig.s3region__c + '",' + 
                '"orgid": "'+ UserInfo.getOrganizationId() + '",' +
                '"filterfield": "'+ 'Id' + '",' +
                '"filtervalue": "'+ soToRestore + '",' +
                '"objecttype": "'+ objToQuery + '",' +
                '"fields": ""' + 
            '}';

            System.debug(content);
            
            String url = gxcSettings.ApiURL + '/audittrail/query';
            GRAXCloud.CallOutResponse callOutRes = GRAXCloud.calloutnow(url, content);

            System.debug(callOutRes);

            if(callOutRes.success) {
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(callOutRes.response);
                for(Object o : (List<Object>)(responseMap.get('data'))) {
                    sobjectToRestore = createSObject(objToQuery, (Map<String, Object>)o);
                }
            }

            System.debug(sobjectToRestore);
        }

        return null;
    }

    public Pagereference saveSObjectToRestore() {
        try {
            insert sobjectToRestore;
        } catch(DMLException e) {
			ApexPages.addMessages(e);
        }

        return null;
    }

    public class ChildRelatedItem {
        public String name {get;set;}
        public String label {get;set;}
        public String relation {get;set;}
        public String value {get;set;}
        public String index {get;set;}

        public ChildRelatedItem(Schema.ChildRelationship childRel, String index) {
            Schema.DescribeSObjectResult childSObjectDescribe = childRel.getChildSObject().getDescribe();

            this.name = childSObjectDescribe.getName();
            this.label = childSObjectDescribe.getLabel();
            this.relation = childRel.getRelationshipName();
            this.value = String.valueOf(childRel.getField());
            this.index = index;
        }
    }

    public String getRelatedJSON() {   
        childRelatedMap = new Map<String, ChildRelatedItem>();

        Integer index = 0;
        Schema.DescribeSObjectResult sObjDesc = globalDescribe.get(parentType).getDescribe();
        for(Schema.ChildRelationship childRel : sObjDesc.getChildRelationships()) {
            if(String.isNotBlank(childRel.getRelationshipName())) {
                ChildRelatedItem cri = new ChildRelatedItem(childRel, String.valueOf(index));
                childRelatedMap.put(cri.index, cri);
                index++;
            }
        }
        
        return JSON.serialize(childRelatedMap.values());
    }


    public String getFieldsJSON() {
        List<Object> fList = new List<Object>();
        Map<String, Object> fMap;
        
        if(String.isNotBlank(objToQuery)) {
            for (Field f : fieldMap.values())
            {
                fMap = new Map<String, Object>();
                fMap.put('id', f.name);
                fMap.put('label', f.label);
                fMap.put('isSelected', false);

                fList.add(fMap);
            }
        }
        
        return JSON.serialize(fList);
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

    public static String ImproveErrorMessage(Exception e){      
        return ImproveErrorMessage(e.getMessage());
    }
    
    public static String ImproveErrorMessage(String msj){
        String result = msj;
        
        if(result.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            Integer lastIndex = result.length();
            if(result.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') < result.lastIndexOf(':')){
                lastIndex = result.lastIndexOf(':');
            }
            result = result.substring(result.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 'FIELD_CUSTOM_VALIDATION_EXCEPTION'.length()+2, lastIndex);
        }
        return result;
    }
}