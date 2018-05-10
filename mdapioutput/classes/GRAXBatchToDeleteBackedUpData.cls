/*****************************************************************************************
Name              : GRAXBatchToDeleteBackedUpData
Description       : This batch process deletes all the SFDC records that have been successfully sent to the GRAX Cloud
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Ariel Yankelevich       05/09/2018           David Mackey        GRAX Archiving -- Salesforce Delete (https://app.asana.com/0/326600806074978/628249897265165/f)
******************************************************************************************/
global class GRAXBatchToDeleteBackedUpData implements Database.Batchable<sObject>, Database.Stateful{
	public String query = '';
    
    public GRAXBatchToDeleteBackedUpData(){
        // Define the main query to retrieve GRAX_Data_Record_Id__c records that have been successfully sent to GRAX
        query = 'SELECT Id, SFDC_Id__c FROM GRAX_Data_Record_Id__c WHERE GRAX_Data_Record__r. AND GRAX_Data_Record__r.GRAX_Schedule_Process__c <> null AND GRAX_Data_Record__r.GRAX_Schedule_Process__r.';
    }
        
    global Database.querylocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
    
    }
    
    global void finish(Database.BatchableContext BC){
    }
}