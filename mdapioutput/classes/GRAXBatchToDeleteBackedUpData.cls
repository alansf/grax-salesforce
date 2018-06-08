/*****************************************************************************************
Name              : GRAXBatchToDeleteBackedUpData
Description       : This batch process deletes all the SFDC records that have been successfully sent to the GRAX Cloud
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Ariel Yankelevich       05/09/2018           David Mackey        GRAX Archiving -- Salesforce Delete (https://app.asana.com/0/326600806074978/628249897265165/f)
2. Ariel Yankelevich       06/05/2018           David Mackey        Backup and Restore Notes & Attachments (https://app.asana.com/0/326600806074978/692982800286805/f)
******************************************************************************************/
global class GRAXBatchToDeleteBackedUpData implements Database.Batchable<sObject>, Database.Stateful{
    public String query = '';
    
    public GRAXBatchToDeleteBackedUpData(){
        // Define the main query to retrieve GRAX_Data_Record_Id__c records that have been successfully sent to GRAX
        query = 'SELECT Id, SFDC_Id__c, GRAX_Data_Record__r.Salesforce_Object__c FROM GRAX_Data_Record_Id__c WHERE GRAX_Data_Record__r.GRAX_Archive_Process__r.Status__c = \'Ready to Delete\'';
    }
        
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Map<Id, SObject> recs2DelByDataRecId = new Map<Id, SObject>();
        List<GRAX_Data_Record_Id__c> dataRecIds2Up= new List<GRAX_Data_Record_Id__c>();
        
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        for(GRAX_Data_Record_Id__c dataRecId : (List<GRAX_Data_Record_Id__c>)scope){
            // Create a new instance of the SObject
            SObject sObj2Del = globalDescribe.get(dataRecId.GRAX_Data_Record__r.Salesforce_Object__c).newSObject(dataRecId.SFDC_Id__c);
            
            recs2DelByDataRecId.put(dataRecId.Id, sObj2Del);
        }
        
        // Delete all the identified records
        List<Database.DeleteResult> deleteResults = Database.delete(recs2DelByDataRecId.values(), false);
        
        List<Id> dataRecIds = new List<Id>(recs2DelByDataRecId.keySet());
        
        // Process the delete results and store the Status of each GRAX_Data_Record_Id__c record
        for(Integer i = 0; i < deleteResults.size(); i++){
            Database.DeleteResult dr = deleteResults[i];
            GRAX_Data_Record_Id__c dataRecId = new GRAX_Data_Record_Id__c(Id = dataRecIds[i]);
            
            dataRecId.Status__c = 'Successfully Deleted';
            
            if(!dr.isSuccess()){
                dataRecId.Status__c = 'Delete Error';
                dataRecId.Error_Description__c = '';
                
                for(Database.Error err : dr.getErrors()) {
                    dataRecId.Error_Description__c += err.getStatusCode() + ': ' + (err.getFields() <> null && err.getFields().size() > 0? '[' + String.join(err.getFields(), ',') + '] ' : '') + err.getMessage() + '.';
                    if(err.getStatusCode() == StatusCode.ENTITY_IS_DELETED){
                        dataRecId.Status__c = 'Deleted with Master Parent';    
                    }
                } 
            }
            
            dataRecIds2Up.add(dataRecId);
        }
        
        update dataRecIds2Up;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}