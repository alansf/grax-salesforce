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
    public Boolean isRelatedRestore {get;set;}
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

    public String idToGetRelated {get;set;}

    public Boolean isReadOnlyMode {get;set;}

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
            strParentId = GRAXUtils.getPageParameter('Id');
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
            isPersonAccount = GRAXUtils.getPageParameter('isPA') == '1';
            contactFields = GRAXUtils.getDescribeFieldsResultForObject('Contact').keySet();
        }

        isRelatedRestore = GRAXUtils.getPageParameter('isRR') == '1';
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

        String res = '{"source":"QueryBackup","status":"success","data":[{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"SDO_A5","Owner_Name":"Krystal Sanchez","Account_Name":"Integrity Systems","What_Name":"Integrity Systems 49","Who_Name":null,"analyticsdemo_batch_id__c":"20170828160320216404","CreatedDate__c":"2017-01-29T22:17:44.000+0000","External_ID__c":"W_Sales_Event.4","DB_Days__c":0,"Type__c":"Call","FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKcQAM","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKKSQA2","AccountId":"0011I00000C3vEhQAJ","EndDateTime":"2017-11-27T08:35:00.000+0000","StartDateTime":"2017-11-27T08:00:00.000+0000","DurationInMinutes":35,"ActivityDate":"2017-11-27","ActivityDateTime":"2017-11-27T08:00:00.000+0000","IsAllDayEvent":false,"Subject":"Account Review","WhatCount":1,"WhoCount":0,"WhatId":"0061I000006YC8jQAG","Id":"00U1I000005YJQUUA4","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJQUUA4","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJQUUA4","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJQUUA4"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJQUUA4"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"SDO_A5","Owner_Name":"Erin Marsh","Account_Name":"Timberlight Technologies","What_Name":"Vans 85","Who_Name":null,"analyticsdemo_batch_id__c":"20170828160320216404","CreatedDate__c":"2017-02-07T21:24:11.000+0000","External_ID__c":"W_Sales_Event.8","DB_Days__c":0,"Type__c":"Call","FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKcQAM","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKKUQA2","AccountId":"0011I00000C3vEjQAJ","EndDateTime":"2017-11-27T08:27:00.000+0000","StartDateTime":"2017-11-27T08:00:00.000+0000","DurationInMinutes":27,"ActivityDate":"2017-11-27","ActivityDateTime":"2017-11-27T08:00:00.000+0000","IsAllDayEvent":false,"Subject":"All Hands Meeting","WhatCount":1,"WhoCount":0,"WhatId":"0061I000006YC8fQAG","Id":"00U1I000005YJQYUA4","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJQYUA4","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJQYUA4","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJQYUA4"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJQYUA4"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"SDO_A5","Owner_Name":"Mark Mayo","Account_Name":null,"What_Name":"00001860","Who_Name":null,"LastModifiedDate__c":"2017-02-11T08:00:00.000+0000","analyticsdemo_batch_id__c":"20170828160151305433","CreatedDate__c":"2017-02-11T08:00:00.000+0000","External_ID__c":"W_Services_Event.9","DB_Days__c":0,"Type__c":"Call","FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKcQAM","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKLHQA2","EndDateTime":"2017-11-27T08:42:00.000+0000","StartDateTime":"2017-11-27T08:00:00.000+0000","DurationInMinutes":42,"ActivityDate":"2017-11-27","ActivityDateTime":"2017-11-27T08:00:00.000+0000","IsAllDayEvent":false,"Subject":"Customer Progress Check-In","WhatCount":1,"WhoCount":0,"WhatId":"5001I000003yewnQAA","Id":"00U1I000005YJQjUAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJQjUAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJQjUAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJQjUAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJQjUAO"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"Adam User","Owner_Name":"Adam User","Account_Name":null,"What_Name":null,"Who_Name":null,"External_ID__c":"Event.123","FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"RecurrenceDayOfWeekMask":32,"RecurrenceInterval":1,"RecurrenceType":"RecursWeekly","RecurrenceTimeZoneSidKey":"America/Los_Angeles","RecurrenceEndDateOnly":"2007-12-28","RecurrenceStartDateTime":"2007-12-01T22:00:00.000+0000","IsRecurrence":true,"RecurrenceActivityId":"00U1I000005YJR6UAO","IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKBQA2","CreatedDate":"2017-11-29T17:55:52.000+0000","GroupEventType":"0","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKKBQA2","EndDateTime":"2007-12-02T00:00:00.000+0000","StartDateTime":"2007-12-01T22:00:00.000+0000","DurationInMinutes":120,"ActivityDate":"2007-12-01","ActivityDateTime":"2007-12-01T22:00:00.000+0000","IsAllDayEvent":false,"Location":"Conference Room 3","Subject":"Weekly Team Meeting","WhatCount":0,"WhoCount":0,"Id":"00U1I000005YJR6UAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJR6UAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJR6UAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJR6UAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJR6UAO"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"Adam User","Owner_Name":"Ely East","Account_Name":null,"What_Name":"1:1 (Me : Ely)","Who_Name":null,"External_ID__c":"Event.067","DB_Days__c":0,"FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":true,"ReminderDateTime":"2015-11-24T17:30:00.000+0000","IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKBQA2","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Call","OwnerId":"0051I000001fKKCQA2","EndDateTime":"2017-11-27T19:00:00.000+0000","StartDateTime":"2017-11-27T17:30:00.000+0000","DurationInMinutes":90,"ActivityDate":"2017-11-27","ActivityDateTime":"2017-11-27T17:30:00.000+0000","IsAllDayEvent":false,"Location":"Conference Room 8","Subject":"Pipeline 1:1","WhatCount":1,"WhoCount":0,"WhatId":"0WD1I000000h1KQWAY","Id":"00U1I000005YJRaUAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJRaUAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJRaUAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJRaUAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJRaUAO"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"Cindy Central","Owner_Name":"Cindy Central","Account_Name":null,"What_Name":null,"Who_Name":null,"External_ID__c":"Event.126","DB_Days__c":0,"FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"ReminderDateTime":"2015-07-13T15:45:00.000+0000","IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKGQA2","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKKGQA2","Description":"This week, present one roadblock you are currently facing, and we will help each other find new ways to approach it.","EndDateTime":"2017-11-27T20:00:00.000+0000","StartDateTime":"2017-11-27T18:30:00.000+0000","DurationInMinutes":90,"ActivityDate":"2017-11-27","ActivityDateTime":"2017-11-27T18:30:00.000+0000","IsAllDayEvent":false,"Location":"Conference Room 6","Subject":"Weekly team meeting","WhatCount":0,"WhoCount":0,"Id":"00U1I000005YJRbUAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJRbUAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJRbUAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJRbUAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJRbUAO"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"Cindy Central","Owner_Name":"Cindy Central","Account_Name":"Tyconet","What_Name":"Tyconet - Add-On Business - 70K","Who_Name":"Sarah Jeffries","External_ID__c":"Event.127","DB_Days__c":0,"FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"ReminderDateTime":"2015-07-13T17:15:00.000+0000","IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKGQA2","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKKGQA2","AccountId":"0011I00000C3vFFQAZ","Description":"First call with this customer about a new opportunity for us.","EndDateTime":"2017-11-27T18:00:00.000+0000","StartDateTime":"2017-11-27T17:00:00.000+0000","DurationInMinutes":60,"ActivityDate":"2017-11-27","ActivityDateTime":"2017-11-27T17:00:00.000+0000","IsAllDayEvent":false,"Location":"Conference Call","Subject":"Discovery and qualification call","WhatCount":1,"WhoCount":1,"WhatId":"0061I000006YCBWQA4","WhoId":"0031I000007CNJlQAO","Id":"00U1I000005YJRcUAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJRcUAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJRcUAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJRcUAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJRcUAO"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"Cindy Central","Owner_Name":"Cindy Central","Account_Name":"Associated Supply Co.","What_Name":"Associated Supply Co. - Add-On Business - 48K","Who_Name":null,"External_ID__c":"Event.135","DB_Days__c":7,"FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKGQA2","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKKGQA2","AccountId":"0011I00000C3vF3QAJ","EndDateTime":"2017-12-04T17:30:00.000+0000","StartDateTime":"2017-12-04T16:30:00.000+0000","DurationInMinutes":60,"ActivityDate":"2017-12-04","ActivityDateTime":"2017-12-04T16:30:00.000+0000","IsAllDayEvent":false,"Location":"Onsite at Customer","Subject":"Close plan review with customer","WhatCount":1,"WhoCount":0,"WhatId":"0061I000006YC9OQAW","Id":"00U1I000005YJRjUAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJRjUAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJRjUAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJRjUAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJRjUAO"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"Cindy Central","Owner_Name":"Cindy Central","Account_Name":"Open Source Inc.","What_Name":"Open Source Inc. - Services - 17K","Who_Name":null,"External_ID__c":"Event.141","DB_Days__c":7,"FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKGQA2","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Call","OwnerId":"0051I000001fKKGQA2","AccountId":"0011I00000C3vF9QAJ","EndDateTime":"2017-12-04T19:30:00.000+0000","StartDateTime":"2017-12-04T18:30:00.000+0000","DurationInMinutes":60,"ActivityDate":"2017-12-04","ActivityDateTime":"2017-12-04T18:30:00.000+0000","IsAllDayEvent":false,"Location":"Call","Subject":"Call with Director of Marketing","WhatCount":1,"WhoCount":0,"WhatId":"0061I000006YCE7QAO","Id":"00U1I000005YJRpUAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJRpUAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJRpUAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJRpUAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJRpUAO"]},{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"Adam User","Owner_Name":"Ely East","Account_Name":null,"What_Name":null,"Who_Name":null,"DB_Days__c":3,"FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKBQA2","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKKCQA2","Description":"Spend time with the customer to understand their needs and timeline for this project.","EndDateTime":"2017-11-30T19:00:00.000+0000","StartDateTime":"2017-11-30T18:00:00.000+0000","DurationInMinutes":60,"ActivityDate":"2017-11-30","ActivityDateTime":"2017-11-30T18:00:00.000+0000","IsAllDayEvent":false,"Location":"Call","Subject":"Discovery Call with Customer","WhatCount":0,"WhoCount":0,"Id":"00U1I000005YJRrUAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJRrUAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJRrUAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJRrUAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJRrUAO"]}],"error":null}';


        /*System.debug(callOutRes);

        if(callOutRes.success) {*/
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res);
            tableRecords = (List<Object>)(responseMap.get('data'));
        //}
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

                    if(typeName == 'Account' && isPersonAccountEnabled && isPersonAccount && f.name == 'RecordTypeId') {
                        so.put('isPersonAccount', true);
                        
                        continue;
                    }

                    if(f.isEditable) {
                        so.put(f.name, val);
                    }
                }
            } catch(Exception e) {
                if(typeName == 'Account' && isPersonAccountEnabled && isPersonAccount && f.name == 'RecordTypeId') {
                   continue; 
                }
                
                ApexPages.addMessages(e);
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

                if(objToQuery == 'Account' && isPersonAccountEnabled && isPersonAccount && (f.name == 'Name' || f.name == 'RecordTypeId')) {
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
        String objToQueryValue = GRAXUtils.getPageParameter('objToQueryValue');

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
        selectedFields = GRAXUtils.getPageParameter('selectedFields');
        selectedFieldsList = selectedFields.split(',');

        filterSearchTerm = GRAXUtils.getPageParameter('filterSearchTerm');

        retriveTableRecords();
        updateSObjectMap();

        return null;
    }

    public Pagereference changeSObjectToRestore() {
        String soToRestore = GRAXUtils.getPageParameter('soToRestore');
        isReadOnlyMode = Boolean.valueOf(GRAXUtils.getPageParameter('isReadOnlyMode'));

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

            /*System.debug(callOutRes);

            if(callOutRes.success) {*/

            String res = '{"source":"QueryBackup","status":"success","data":[{"LastModifiedBy_Name":"Joe Gaska","CreatedBy_Name":"Cindy Central","Owner_Name":"Cindy Central","Account_Name":null,"What_Name":null,"Who_Name":null,"External_ID__c":"Event.126","DB_Days__c":0,"FSL__Count_of_Tasks__c":0,"FSL__Count_of_Events__c":1,"EventSubtype":"Event","IsReminderSet":false,"ReminderDateTime":"2015-07-13T15:45:00.000+0000","IsRecurrence":false,"IsVisibleInSelfService":false,"IsArchived":false,"SystemModstamp":"2017-11-29T17:55:52.000+0000","LastModifiedById":"0051I000000bfBQQAY","LastModifiedDate":"2017-11-29T17:55:52.000+0000","CreatedById":"0051I000001fKKGQA2","CreatedDate":"2017-11-29T17:55:52.000+0000","IsGroupEvent":false,"IsChild":false,"IsDeleted":false,"ShowAs":"Busy","IsPrivate":false,"Type":"Meeting","OwnerId":"0051I000001fKKGQA2","Description":"This week, present one roadblock you are currently facing, and we will help each other find new ways to approach it.","EndDateTime":"2017-11-27T20:00:00.000+0000","StartDateTime":"2017-11-27T18:30:00.000+0000","DurationInMinutes":90,"ActivityDate":"2017-11-27","ActivityDateTime":"2017-11-27T18:30:00.000+0000","IsAllDayEvent":false,"Location":"Conference Room 6","Subject":"Weekly team meeting","WhatCount":0,"WhoCount":0,"Id":"00U1I000005YJRbUAO","attributes":{"url":"/services/data/v43.0/sobjects/Event/00U1I000005YJRbUAO","type":"Event"},"graxorgid":"00D1I000003nRMaUAM","graxid":"00D1I000003nRMaUAM_00U1I000005YJRbUAO","grax_event_xf":["00D1I000003nRMaUAM_00U1I000005YJRbUAO"],"grax_xf":["00D1I000003nRMaUAM_00U1I000005YJRbUAO"]}],"error":null}';
            
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res);
                for(Object o : (List<Object>)(responseMap.get('data'))) {
                    sobjectToRestore = createSObject(objToQuery, (Map<String, Object>)o);
                }
            //}

            System.debug(sobjectToRestore);
        }

        return null;
    }

    public Pagereference saveSObjectToRestore() {
        System.debug(JSON.serializePretty(sobjectToRestore));

        if(ApexPages.getMessages().size() == 0) {
            try {
                insert sobjectToRestore;
            } catch (System.FinalException f){
                ApexPages.addMessages(f);
            } catch(Exception e) {
                ApexPages.addMessages(e);
            }
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

    
    public Pagereference changeIdToGetRelated() {
        idToGetRelated = GRAXUtils.getPageParameter('idToGetRelated');

        return null;
    }

    public String getRelatedIframeUrl() {
        String restoreURL = 'javascript:void(0);';

        if(String.isNotBlank(idToGetRelated)) {
            restoreURL = '/apex/GRAXRestore?Id=' + idToGetRelated + '&isRR=1';

            if(isPersonAccountEnabled && objToQuery == 'Account') {
                restoreURL += '&isPA=' + (isPersonAccount ? '1' : '0');
            }
        }

        return restoreURL;
    }
}