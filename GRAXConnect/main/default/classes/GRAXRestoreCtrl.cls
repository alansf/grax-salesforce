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
    public Map<String, Map<String, String>> objectMap {get;set;}
    public SObject sobjectToRestore {get;set;}
    public Map<String, ChildRelatedItem> childRelatedMap {get;set;}

    public Map<String, Field> fieldMap {get;set;}
    public Set<String> fieldSetToExclude = new Set<String>{'Id', 'IsDeleted', 'SystemModstamp'};
    public Map<String, Set<String>> fieldsToExcludeByObject = new Map<String, Set<String>>{
        'Case' => new Set<String>{'Comments'}
    };

    public List<Object> tableRecords {get;set;}
    public String selectedFields {get;set;}

    public String objToQuery {get;set;}
    public String relToQuery {get;set;}

    public Boolean isMasterRestore {get;set;}
    public String filterSearchTerm {get;set;}

    public Boolean isPersonAccountEnabled = false;
    public Boolean isPersonAccount {get;set;}

    public Set<String> contactFields;
    public Set<String> accountContactCommonFields = new Set<String>{
        'Id', 'IsDeleted', 'MasterRecordId', 'Phone', 'Name',
        'Fax', 'PhotoUrl', 'Description', 'OwnerId', 'CreatedDate',
        'CreatedById', 'LastModifiedDate', 'LastModifiedById',
        'SystemModstamp', 'LastActivityDate', 'LastViewedDate',
        'LastReferencedDate', 'Jigsaw', 'CleanStatus'
    };

    public class Field {
        public String name {get;set;}
        public String label {get;set;}
        public String type {get;set;}

        public Boolean isCreateable {get;set;}
        public Boolean isNamePointing {get;set;}
        public Boolean isReference {get;set;}
        public Boolean isSearchPrefilterable {get;set;}

        public Boolean isEditable {get;set;}

        public String containerClass;
        public String styleClass;

        public Field(Schema.DescribeFieldResult fd) {
            this.name = fd.getName();
            this.label = GRAXUtils.CleanFieldLabel(fd, true);
            this.type = fd.getType().name();

            this.isCreateable = fd.isCreateable();
            this.isNamePointing = fd.isNamePointing();
            this.isReference = fd.getReferenceTo().size() > 0;
            this.isSearchPrefilterable = fd.isSearchPrefilterable();

            this.isEditable = true;
        }

        public String getStyleClass() {
            String cls = 'slds-input';

            if(type == 'REFERENCE' && isNamePointing) {
                cls = 'is-name-pointing';
            }

            if(type == 'PICKLIST' || (type == 'REFERENCE' && !isSearchPrefilterable)) {
                cls = 'slds-select';
            }

            if(type == 'TEXTAREA') {
                cls = 'slds-textarea';
            }

            return cls;
        }

        public String getContainerClass() {
            String cls = '';

            if(type == 'REFERENCE' || isSearchPrefilterable) {
                cls = 'slds-input-has-icon slds-input-has-icon_right';
            }

            if(type == 'PICKLIST' || (type == 'REFERENCE' && !isSearchPrefilterable)) {
                cls = 'slds-select_container';
            }

            if(type == 'BOOLEAN') {
                cls = 'slds-checkbox';
            }

            return cls;
        }
    }

    public GRAXRestoreCtrl() {
        objToQuery = '';

        fieldMap = new Map<String, Field>();
        sObjectMap = new Map<String, SObject>();
        objectMap = new Map<String, Map<String, String>>();
        tableRecords = new List<Object>();

        String strParentId;
        try {
            strParentId = Apexpages.currentPage().getParameters().get('Id');
        } catch(Exception e) {}

        if(String.isNotBlank(strParentId)) {
            parentId = Id.valueOf(strParentId);
            parentType = parentId.getSObjectType().getDescribe().getName();
            isMasterRestore = false;
        } else {
            isMasterRestore = true;
        }

        isPersonAccountEnabled = GRAXUtils.isPersonAccountEnabled();
        if(isPersonAccountEnabled) {
            isPersonAccount = false;
            contactFields = GRAXUtils.getDescribeFieldsResultForObject('Contact').keySet();
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
            '"objecttype": "'+ objToQuery + '",';

        if(isMasterRestore) {

            if(isPersonAccountEnabled && objToQuery == 'Account') {
                if(!String.isEmpty(filterSearchTerm)) {
                    filterSearchTerm += ' AND ';
                }

                filterSearchTerm += 'doc.IsPersonAccount:' + String.valueOf(isPersonAccount);
            }

            System.debug(filterSearchTerm);

            content += '"esendpoint":"https://search-grax-sales-demo-2vurmmexs6c444alo45eyyzwea.us-east-2.es.amazonaws.com",' +
                '"query": "' + filterSearchTerm + '"';
        } else {
            content += '"filterfield": "'+ relToQuery + '",' +
                '"filtervalue": "'+ parentId + '",' +
                '"fields": "Id,'+ selectedFields + '"';
        }
        
        content += '}';
        
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
        SObject so = GRAXUtils.createObjectInstance(typeName);

        for(Field f : fieldMap.values()) {
            try {
                if(f.isCreateable) {
                    Object val = GRAXUtils.castGenericObjectToType(mo.get(f.name), f.type);
                    
                    if(f.isReference && !GRAXUtils.idExist((String)val)) {
                        continue;
                    }

                    if(isPersonAccountEnabled && isPersonAccount && f.name == 'RecordTypeId') {
                        so.put('isPersonAccount', true);
                        
                        continue;
                    }

                    if(f.isEditable) {
                        so.put(f.name, val);
                    }
                }
            } catch(Exception e) {
                System.debug(LoggingLevel.WARN, e.getMessage() + ' on field ' + f.label);
            }
        }

        return so;
    }

    public Map<String, String> createObjectMap(Map<String, Object> mo) {
        Map<String, String> m = new Map<String, String>();

        for(Field f : fieldMap.values()) {

            if(!f.isCreateable || !f.isEditable) {
                Object val = GRAXUtils.castGenericObjectToType(mo.get(f.name), f.type);

                m.put(f.name, String.valueOf(val));
            }
            
        }

        return m;
    }

    public void updateSObjectMap() {
        sObjectMap.clear();
        objectMap.clear();

        if(String.isNotBlank(objToQuery)) {
            for(Object o : tableRecords) {
                Map<String, Object> mo = (Map<String, Object>)o;
                SObject so = createSObject(objToQuery, mo);

                sObjectMap.put((String)mo.get('Id'), so);
                objectMap.put((String)mo.get('Id'), createObjectMap(mo));
            }
        }
    }

    public void updateSObjectFields(){
        fieldMap.clear();

        Boolean addField = false;
        
        if(String.isNotBlank(objToQuery)) {
            for(Schema.DescribeFieldResult fd : GRAXUtils.getDescribeFieldsResultForObject(objToQuery).values()) {
                Field f = new Field(fd);

                addField = !fieldSetToExclude.contains(f.name) && (!fieldsToExcludeByObject.containsKey(objToQuery) || !fieldsToExcludeByObject.get(objToQuery).contains(f.name));

                if(objToQuery == 'Account' && isPersonAccountEnabled && !isPersonAccount) {
                    addField &= accountContactCommonFields.contains(f.name) || !contactFields.contains(f.name);
                    addField &= !f.name.endsWith('__pc');
                }

                if(isPersonAccountEnabled && isPersonAccount && (f.name == 'Name' || f.name == 'RecordTypeId')) {
                    f.isEditable = false;
                }

                if(addField) {
                    fieldMap.put(f.name, f);
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
        String objToQueryValue = Apexpages.currentPage().getParameters().get('objToQueryValue');

        if(objToQueryValue == 'Account2') {
            objToQueryValue = 'Account';
            isPersonAccount = true;
        }
        
        if(String.isNotBlank(objToQueryValue)) {
            if(isMasterRestore) {
                objToQuery = objToQueryValue;
            } else {
                objToQuery = childRelatedMap.get(objToQueryValue).name;
                relToQuery = childRelatedMap.get(objToQueryValue).value;
            }

            updateSObjectFields();
        }
        
        return null;
    }

    public Pagereference updateDataTable() {
        selectedFields = Apexpages.currentPage().getParameters().get('selectedFields');
        selectedFieldsList = selectedFields.split(',');

        filterSearchTerm = Apexpages.currentPage().getParameters().get('filterSearchTerm');

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
        System.debug(JSON.serializePretty(sobjectToRestore));

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
        for(Schema.ChildRelationship childRel : GRAXUtils.getObjectDescribe(parentType).getChildRelationships()) {
            if(String.isNotBlank(childRel.getRelationshipName())) {
                ChildRelatedItem cri = new ChildRelatedItem(childRel, String.valueOf(index));
                childRelatedMap.put(cri.index, cri);
                index++;
            }
        }
        
        return JSON.serialize(childRelatedMap.values());
    }

    public List<SelectOption> getItems() {
        String objectname;
        List<SelectOption> options = new List<SelectOption>();
        Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();
            options.add(new SelectOption('' ,'-- SELECT SALESFORCE OBJECT --', true));
        for (String apiName : sObjects.keySet())
        {
            Map<String, Schema.RecordTypeInfo> types = sObjects.get(apiName).getDescribe().getRecordTypeInfosByName();
            if (types.size() > 0){
                objectname = sObjects.get(apiName).getDescribe().getName();
                options.add(new SelectOption(objectname ,objectname ));
            }
        }

        if(isPersonAccountEnabled) {
            options.add(new SelectOption('Account2', 'Account (Person)'));
        }

        options.sort();
        
        return options;
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
}