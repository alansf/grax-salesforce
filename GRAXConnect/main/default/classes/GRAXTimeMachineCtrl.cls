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
    public Boolean isTest = false;
    public String GRAXFileDataTest;

	private List<Object> oldState {get;set;}
	private List<Object> newState {get;set;}

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
        isTest = Test.isRunningTest();
        
		userTimeZone = UserInfo.getTimeZone().getID();
        graxConfig = GRAXSettings__c.getOrgDefaults();
        strParentId = Apexpages.currentPage().getParameters().get('Id');
        
        if(String.isNotBlank(strParentId)) {
            parentId = (Id)strParentId;
            parentType = parentId.getSObjectType().getDescribe().getName();
            timeMachine = GRAXAuditTrail.GetTimeMachine(parentType,parentId);
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
        String GRAXFileData;
        if(this.isTest) {
            GRAXFileData = this.GRAXFileDataTest;
        } else {
            GRAXFileData = GRAXAuditTrail.GetTimeMachineFile(parentType, parentId, fileName);
        }
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

        Map<String, List<SelectOption>> fileSelectMap = new Map<String, List<SelectOption>>();

        if(this.isTest) {
        
            for(Integer i=10; i <= 14; i++) {
                String datetimeString = '2018-06-' + i + 'T18:57:24.000Z';
                Datetime updatedDate = (Datetime)GRAXUtils.castGenericObjectToType(datetimeString, 'datetime');
                
                if(!fileSelectMap.containsKey(datetimeString)) {
                    fileSelectMap.put(datetimeString, new List<SelectOption>());
                }
                
                fileSelectMap.get(datetimeString).add(new SelectOption('grax/audittrail/salesforce/00D1I000003nRMaUAM/Case/5001I000003yey4QAA/2018-06-' + i + 'T18-57-24-000-0000.json', updatedDate.format('MM/dd/yyyy HH:mm', userTimeZone)));
            }

        } else {
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
                                Datetime updatedDate = (Datetime)GRAXUtils.castGenericObjectToType(FieldValue, 'datetime');

                                if(!fileSelectMap.containsKey(FieldValue)) {
                                    fileSelectMap.put(FieldValue, new List<SelectOption>());
                                }

                                fileSelectMap.get(FieldValue).add(new SelectOption(S3Key, updatedDate.format('MM/dd/yyyy HH:mm', userTimeZone)));
                            }                           
                        }   
                    }
                }
    
            } catch (Exception e) {
                System.debug(e);
            } finally {
                //optional finally block
                //code to run whether there is an exception or not
            }
        }

        List<String> keyList = new List<String>(fileSelectMap.keySet());
        keyList.sort();

        for(Integer i = keyList.size() - 1; i >= 0; i--) {
            fileSelect.addAll(fileSelectMap.get(keyList[i]));
        }

		if(fileSelect.size() > 0) {
			olderBackup = fileSelect.get(0);
		}

        return fileSelect;
    }

    public String getFileSelectJson() {
        List<Object> sopList = new List<Object>();
        Map<String, Object> sopMap;

        for (SelectOption sop : fileSelect) {
            sopMap = new Map<String, Object>();
            sopMap.put('value', sop.getValue());
            sopMap.put('label', sop.getLabel());

            sopList.add(sopMap);
        }
        
        return JSON.serialize(sopList);
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

        for(Schema.DescribeFieldResult fd : GRAXUtils.getDescribeFieldsResultForObject(sObjectName).values()) {
            Field f = new Field(fd);

            if(f.isUpdateable) {
                fieldsMap.put(f.name, f);
            }
        }

        return fieldsMap;
    }

    public static List<String> getFieldListBySObjectName(String sObjectName) {
        return new List<String>(getFieldsMapBySObjectName(sObjectName).keySet());
    }

    public void updateSObject(Id soId, Map<String, Object> mo) {
        SObject so = getSObjectById(soId);

		Map<String, Field> fieldMap = getFieldsMapBySObjectName(this.parentType);

        for(Field f : fieldMap.values()) {
            try {
                if(f.isUpdateable && mo.containsKey(f.name)) {
                    so.put(f.name, GRAXUtils.castGenericObjectToType(mo.get(f.name), f.type));
                }
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

        public Boolean isDifferent {get;set;}

        public MapFieldDiff(Object oldValue, Object newValue) {
			this.oldValue = oldValue;
			this.newValue = newValue;

            this.isDifferent = oldValue <> newValue;
		}

        public String getStyleClass() {
            return this.isDifferent ? 'isDifferent' : '';
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

		Map<String, Field> fieldMap = getFieldsMapBySObjectName(this.parentType);

		Map<String, Object> oldMap = (Map<String, Object>)(oldState.get(0));
		Map<String, Object> newMap = (Map<String, Object>)(newState.get(0));

        for(Field f : fieldMap.values()) {
			if(f.isUpdateable) {
                MapFieldDiff mfd = new MapFieldDiff(getMapValue(oldMap, f.name), getMapValue(newMap, f.name));

				diff.put(f.Name, mfd);
			}
        }

		return diff;
	}
}
