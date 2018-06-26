/*****************************************************************************************
Name              : GRAXTimeMachineCtrl
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
******************************************************************************************/
public with sharing class GRAXTimeMachineCtrl {
	public Id parentId {get;set;}
	public String parentType {get;set;}
	public GRAXSettings__c graxConfig {get;set;}
	public String timeMachine {get;set;}
	public List<SelectOption> fileSelect {get;set;}
	String fileSelected = null;
	public String fileContents {get;set;}
	String strParentId;
	
    public GRAXTimeMachineCtrl() {
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
    
    
    // TODO : We should parse the JSON display the differences between NEW and OLD in JSON                
    public void setfileSelected(String currentFile) { 
    		this.fileSelected = currentFile; 
    		String fileName = currentFile.split('/')[currentFile.split('/').size()-1];
    		String GRAXFileData = GRAXAuditTrail.GetTimeMachineFile(parentType,strParentId,fileName);
    		this.fileContents = GRAXFileData;
    	}
    
    public List<SelectOption> ParseJSON(String graxconfig){
    		String FieldName = '';
    		String FieldValue = '';
    		String S3Key = '';
    		fileSelect = new List<SelectOption>();
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
	        					fileSelect.add(new SelectOption(S3Key,FieldValue));
	        				}	        				
	        			}	
	        		}
	        }
		} catch (Exception e) {
		     //Generic exception handling code here
		} finally {
		     //optional finally block
		     //code to run whether there is an exception or not
		}
        fileSelect.sort();
        return fileSelect;
   	}
   	
   	public PageReference test() {
 	 	return null;
 	}
}
