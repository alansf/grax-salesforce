/*****************************************************************************************
Name              : GRAXTimeMachineCtrl
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
******************************************************************************************/
public with sharing class GRAXTimeMachineCtrl {
    public Id parentId {get;set;}
	public String userTimeZone {get;set;}
    public String parentType {get;set;}
    public GRAXSettings__c graxConfig {get;set;}
    public String timeMachine {get;set;}
    public List<SelectOption> fileSelect {get;set;}
    String fileSelected = null;
    public String fileContents {get;set;}
    String strParentId;
	public SelectOption olderBackup {get;set;}
	public Boolean showRestoreToOldVersionButton {get;set;}

	private List<Object> oldState {get;set;}
	private List<Object> newState {get;set;}

	public static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

	public class Field {
        public String name {get;set;}
        public String label {get;set;}
        public String type {get;set;}

        public Boolean isCreateable {get;set;}
        public Boolean isUpdateable {get;set;}

        public Field(Schema.DescribeFieldResult fd) {
            this.name = fd.getName();
            this.label = CleanFieldLabel(fd, true);
            this.type = fd.getType().name();

			this.isCreateable = fd.isCreateable();
            this.isUpdateable = fd.isUpdateable();
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
    
    public GRAXTimeMachineCtrl() {
		userTimeZone = UserInfo.getTimeZone().getID();
            graxConfig = GRAXSettings__c.getOrgDefaults();
        strParentId = Apexpages.currentPage().getParameters().get('Id');
        if(String.isNotBlank(strParentId)) {
            parentId = Id.valueOf(strParentId);
            parentType = parentId.getSObjectType().getDescribe().getName();
            timeMachine = GRAXAuditTrail.GetTimeMachine(parentType,strParentId);
            fileSelect = ParseJSON(timeMachine);
        }
    }
    
    public String getfileSelected() {
        return fileSelected;
    }

	public Boolean getHasBackups() {
		return fileSelect.size() > 0;
	}

	public Boolean getIsFileSelected() {
		return fileSelected <> null;
	}
    
    
    // TODO : We should parse the JSON display the differences between NEW and OLD in JSON                
    public void setfileSelected(String currentFile) { 
		this.fileSelected = currentFile; 
		String fileName = currentFile.split('/')[currentFile.split('/').size()-1];
		String GRAXFileData = GRAXAuditTrail.GetTimeMachineFile(parentType,strParentId,fileName);
		//String GRAXFileData = '{"error":null,"data":{"old":[{"LastModifiedById":"0051I000000bfBQQAY","Channel__c":"_IM1_/servlet/servlet.ImageServer?id=0151I000001MHd6&oid=00D1I000003nRMa_IM2_ _IM3__22_IM4_22_IM5_","ClosedDate":"2015-06-02T12:56:34.000+0000","ContactEmail":"drose@example.com","EventsProcessedDate":"2012-05-17T14:17:59.000+0000","Quality_Score__c":6,"Type":"Account Support","SystemModstamp":"2018-05-19T10:49:32.000+0000","Subject":"Bill payment clarification.","Product_Name__c":"Product A","IsLocked":false,"IsVisibleInSelfService":true,"MayEdit":false,"DateTime_Opened_c__c":"2017-08-02T23:56:39.000+0000","LastModifiedByAlias":"JGask","HasSelfServiceComments":false,"Send_Email_Trigger__c":false,"ContactFax":"(575) 555-0199","CaseNumber":"00001167","Status_Indicator__c":"_IM1_/servlet/servlet.ImageServer?id=0151I000001MHcK&oid=00D1I000003nRMa_IM2_Status_IM3__24_IM4_24_IM5_","RecordTypeId":"0121I0000018KktQAE","Case_Survey_URL__c":"https://demohardingpoint200.my.salesforce.com/apex/DE_CustomerSurvey","OwnerId":"0051I000001fKLhQAM","ED_Leading_Causes__c":"- 3.135 because Origin is Phone and Offer Voucher is false<br>- 3.017 because Origin is Phone and Send Field Service is false<br>- 1.555 because Origin is Phone<br>- 5.009 because of other factors<br>from the baseline, + 40.587","Response_Time_mins__c":10,"ContactPhone":"(575) 555-2613","Reason":"New problem","ContactId":"0031I000007CNJiQAO","ED_Outcome__c":77.053,"IsClosed":true,"KB_Article_Attached__c":false,"Description":"I seem to have misplaced my last bill, and I want to be sure that it\'s paid. Can you please check this for me?","DB_Case_Duration_Hours__c":16,"Send_FieldService__c":false,"Custom_Date_Field__c":"2018-05-15","Cost__c":1.75,"Type_of_Support__c":"Standard","IsVisibleInCss":false,"Id":"5001I000003yey4QAA","CreatedDate":"2017-11-29T17:55:52.000+0000","IsEscalated":false,"IsStopped":false,"DateTime_Closed_c__c":"2017-08-03T15:56:39.000+0000","EDY_ORGCUSTOM__DB__c":false,"First_Contact_Close__c":false,"CreatedByAlias":"AUser","Community_Contact_Match__c":false,"Priority":"Critical","Duration__c":5.33,"HasCommentsUnreadByOwner":false,"IsDeleted":false,"ContactMobile":"(575) 555-0188","Status":"Closed","CSAT__c":95,"Volume__c":1140,"ED_Prescription__c":"+ 7.949 if you change Offer Voucher to true<br>+ 9.998 if you change Send Field Service to true","IsClosedOnCreate":false,"ClosedOnCreate":false,"Offer_Voucher__c":false,"CreatedById":"0051I000001fKKBQA2","Sub_Type__c":"Other","Urgency__c":"_IM1_/servlet/servlet.ImageServer?id=0151I000001MHcg&oid=00D1I000003nRMa_IM2_ _IM3__22_IM4_22_IM5_","BusinessHoursId":"01m1I000000qpUWQAY","IsSelfServiceClosed":false,"SLA_Compliant__c":true,"DB_Hours__c":-2800,"ProductId":"01t1I000001KKNRQA4","External_ID__c":"Case.076","AccountId":"0011I00000C3vFCQAZ","LastModifiedDate":"2018-05-18T19:17:13.000+0000","Origin":"Community","attributes":{"url":"/services/data/v43.0/sobjects/Case/5001I000003yey4QAA","type":"Case"}}],"new":[{"LastModifiedById":"0051I000000bfBQQAY","Channel__c":"_IM1_/servlet/servlet.ImageServer?id=0151I000001MHd6&oid=00D1I000003nRMa_IM2_ _IM3__22_IM4_22_IM5_","ClosedDate":"2015-06-02T12:56:34.000+0000","ContactEmail":"drose@example.com","EventsProcessedDate":"2012-05-17T14:17:59.000+0000","Quality_Score__c":6,"Type":"General","SystemModstamp":"2018-06-25T18:57:26.000+0000","Subject":"Bill payment clarification.","Product_Name__c":"Product A","IsLocked":false,"IsVisibleInSelfService":true,"MayEdit":false,"DateTime_Opened_c__c":"2017-08-02T23:56:39.000+0000","LastModifiedByAlias":"JGask","HasSelfServiceComments":false,"Send_Email_Trigger__c":false,"ContactFax":"(575) 555-0199","CaseNumber":"00001167","Status_Indicator__c":"_IM1_/servlet/servlet.ImageServer?id=0151I000001MHcK&oid=00D1I000003nRMa_IM2_Status_IM3__24_IM4_24_IM5_","RecordTypeId":"0121I0000018KktQAE","Case_Survey_URL__c":"https://demohardingpoint200.my.salesforce.com/apex/DE_CustomerSurvey","OwnerId":"0051I000001fKLhQAM","ED_Leading_Causes__c":"- 3.135 because Origin is Phone and Offer Voucher is false<br>- 3.017 because Origin is Phone and Send Field Service is false<br>- 1.555 because Origin is Phone<br>- 6.071 because of other factors<br>from the baseline, + 39.525","Response_Time_mins__c":10,"ContactPhone":"(575) 555-2613","Reason":"New problem","ContactId":"0031I000007CNJiQAO","ED_Outcome__c":77.053,"IsClosed":true,"KB_Article_Attached__c":false,"Description":"I seem to have misplaced my last bill, and I want to be sure that it\'s paid. Can you please check this for me?","DB_Case_Duration_Hours__c":16,"Send_FieldService__c":false,"Custom_Date_Field__c":"2018-05-15","Cost__c":1.75,"Type_of_Support__c":"Standard","IsVisibleInCss":false,"Id":"5001I000003yey4QAA","CreatedDate":"2017-11-29T17:55:52.000+0000","IsEscalated":false,"IsStopped":false,"DateTime_Closed_c__c":"2017-08-03T15:56:39.000+0000","EDY_ORGCUSTOM__DB__c":false,"First_Contact_Close__c":false,"CreatedByAlias":"AUser","Community_Contact_Match__c":false,"Priority":"High","Duration__c":5.33,"HasCommentsUnreadByOwner":false,"IsDeleted":false,"ContactMobile":"(575) 555-0188","Status":"Closed","CSAT__c":95,"Volume__c":1140,"ED_Prescription__c":"+ 7.949 if you change Offer Voucher to true<br>+ 9.998 if you change Send Field Service to true","IsClosedOnCreate":false,"ClosedOnCreate":false,"Offer_Voucher__c":false,"CreatedById":"0051I000001fKKBQA2","Sub_Type__c":"Other","Urgency__c":"_IM1_/servlet/servlet.ImageServer?id=0151I000001MHch&oid=00D1I000003nRMa_IM2_ _IM3__22_IM4_22_IM5_","BusinessHoursId":"01m1I000000qpUWQAY","IsSelfServiceClosed":false,"SLA_Compliant__c":true,"DB_Hours__c":-2800,"ProductId":"01t1I000001KKNRQA4","External_ID__c":"Case.076","AccountId":"0011I00000C3vFCQAZ","LastModifiedDate":"2018-06-25T18:57:26.000+0000","Origin":"Community","attributes":{"url":"/services/data/v43.0/sobjects/Case/5001I000003yey4QAA","type":"Case"}}]},"status":"success","source":"GetFile"}';
		Map<String, Object> o = (Map<String, Object>)JSON.deserializeUntyped(GRAXFileData);
		Map<String, Object> data = (Map<String, Object>)(o.get('data'));

		oldState = (List<Object>)(data.get('old'));
		newState = (List<Object>)(data.get('new'));

		showRestoreToOldVersionButton = olderBackup.getValue() == currentFile;
		showRestoreToOldVersionButton &= oldState <> null;
		showRestoreToOldVersionButton &= !oldState.isEmpty();

		this.fileContents = JSON.serializePretty(o);
	}
    
    public List<SelectOption> ParseJSON(String graxconfig){
            String FieldName = '';
            String FieldValue = '';
            String S3Key = '';
            fileSelect = new List<SelectOption>();

			Map<String, SelectOption> fileSelectMap = new Map<String, SelectOption>();

            try{
                if (String.isNotBlank(graxconfig)){
                    JSONParser parser = JSON.createParser(graxconfig);
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
                        {
                            FieldName = parser.getText();
                            parser.nextToken();
                            FieldValue = parser.getText();
                            if (FieldName=='Key')
                                S3Key = FieldValue;
                            if (FieldName=='LastModified'){
								Datetime updatedDate = (Datetime)GRAXRestoreCtrl.castGenericObjectToType(FieldValue, 'datetime');

								fileSelectMap.put(FieldValue, new SelectOption(S3Key, updatedDate.format('MM/dd/yyyy HH:mm', userTimeZone)));
                            }                           
                        }   
                    }
            }

			/*
			Datetime updatedDate = (Datetime)GRAXRestoreCtrl.castGenericObjectToType('2018-06-24T18:57:29.000Z', 'datetime');

			fileSelectMap.put('2018-06-25T18:57:29.000Z', new SelectOption('grax/audittrail/salesforce/00D1I000003nRMaUAM/Case/5001I000003yey4QAA/2018-06-25T18-57-25-000-0000.json', '2018-06-25T18:57:29.000Z'));
			fileSelectMap.put('2018-06-26T18:57:29.000Z', new SelectOption('grax/audittrail/salesforce/00D1I000003nRMaUAM/Case/5001I000003yey4QAA/2018-06-25T18-57-26-000-0000.json', '2018-06-26T18:57:29.000Z'));
			fileSelectMap.put('2018-06-24T18:57:29.000Z', new SelectOption('grax/audittrail/salesforce/00D1I000003nRMaUAM/Case/5001I000003yey4QAA/2018-06-25T18-57-24-000-0000.json', updatedDate.format('MM/dd/yyyy HH:mm', userTimeZone)));
			*/

			List<String> keyList = new List<String>(fileSelectMap.keySet());
			keyList.sort();

			for(Integer i = keyList.size() - 1; i >= 0; i--) {
				fileSelect.add(fileSelectMap.get(keyList[i]));
			}
        } catch (Exception e) {
             //Generic exception handling code here
        } finally {
             //optional finally block
             //code to run whether there is an exception or not
        }
        fileSelect.sort();

		if(fileSelect.size() > 0) {
			olderBackup = fileSelect.get(0);
		}

        return fileSelect;
    }
    
    public Pagereference changeFileSelected() {
        String fileSelected = Apexpages.currentPage().getParameters().get('fileSelected');

		if(String.isNotBlank(fileSelected)) {
			setfileSelected(fileSelected);
		}

		return null;
	}

	public static SObject getSObjectById(Id sId) {
        String sObjectName = getSObjectNameById(sId);
        String sObjectFields = String.join(getFieldListBySObjectName(sObjectName), ', ');

        return Database.query('SELECT ' + sObjectFields + ' FROM ' + sObjectName + ' WHERE Id = :sId LIMIT 1');
    }

    public static String getSObjectNameById(Id sId) {
        return sId.getSObjectType().getDescribe().getName();
    }

	public static Map<String, Field> getFieldsMapBySObjectName(String sObjectName) {
        Map<String, Field> fieldsMap = new Map<String, Field>();

        Map<String, Schema.SObjectField> fMap = globalDescribe.get(sObjectName).getDescribe().Fields.getMap();
        
        if(fMap != null){
            for(Schema.SObjectField ft : fMap.values()) {
                Field f = new Field(ft.getDescribe());

                if(f.isUpdateable) {
                    fieldsMap.put(f.name, f);
                }
            }
        }

        return fieldsMap;
    }

    public static List<String> getFieldListBySObjectName(String sObjectName) {
        return new List<String>(getFieldsMapBySObjectName(sObjectName).keySet());
    }

    public void updateSObject(Id soId, Map<String, Object> mo) {
        SObject so = getSObjectById(soId);
		Map<String, Field> fieldMap = getFieldsMapBySObjectName(getSObjectNameById(soId));

        for(Field f : fieldMap.values()) {
            try {
                if(f.isUpdateable) so.put(f.name, GRAXRestoreCtrl.castGenericObjectToType(mo.get(f.name), f.type));
            } catch(Exception e) {
                System.debug(LoggingLevel.WARN, e.getMessage() + ' on field ' + f.label);
            }
        }

		update so;
    }

	public Pagereference restoreToOldVersion() {
		for(Object o : oldState) {
			updateSObject(parentId, (Map<String, Object>)o);
		}

		return null;
	}

	public Pagereference updateToThisVersion() {
        for(Object o : newState) {
			updateSObject(parentId, (Map<String, Object>)o);
		}

		return null;
	}

	public class MapFieldDiff {
        public Object oldValue {get;set;}
        public Object newValue {get;set;}

        public MapFieldDiff(Object oldValue, Object newValue) {
			this.oldValue = oldValue;
			this.newValue = newValue;
		}

		public Boolean isDifferent() {
			return oldValue <> newValue;
		}
	}

	public Object getMapValue(Map<String, Object> m, String key) {
		if(m.containsKey(key)) {
			return m.get(key);
		}

		return null;
	}

	public Map<String, MapFieldDiff> getDiff() {
		Map<String, MapFieldDiff> diff = new Map<String, MapFieldDiff>();

		Map<String, Field> fieldMap = getFieldsMapBySObjectName(getSObjectNameById(this.parentId));

		Map<String, Object> oldMap = (Map<String, Object>)(oldState.get(0));
		Map<String, Object> newMap = (Map<String, Object>)(newState.get(0));

        for(Field f : fieldMap.values()) {
			MapFieldDiff mfd = new MapFieldDiff(getMapValue(oldMap, f.name), getMapValue(newMap, f.name));

			if(f.isUpdateable && mfd.isDifferent()) {
				diff.put(f.Name, mfd);
			}
        }

		return diff;
	}
}
