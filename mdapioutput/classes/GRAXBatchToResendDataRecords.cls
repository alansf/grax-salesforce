/*****************************************************************************************
Name              : GRAXBatchToResendDataRecords
Description       : Try again to do up to 5 times the Callout of the records that were not sent correctly.
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
******************************************************************************************/
global class GRAXBatchToResendDataRecords implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public Boolean isExecuteNow = false;
    public Boolean isArchive = false;
    public Id currentJobId;

    global Database.querylocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Salesforce_Object__c, of_Times_Sent__c FROM GRAX_Data_Record__c WHERE Status__c <> \'Sent Successful\' AND of_Times_Sent__c < 5';

        if(isExecuteNow && currentJobId <> null) {
            query += ' AND GRAX_Schedule_Process__c = :currentJobId';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<GRAX_Data_Record__c> scope) {
        List<GRAX_Data_Record__c> dataRecords2Up = new List<GRAX_Data_Record__c>();
        
        for(GRAX_Data_Record__c dr : scope) {
            String content;

            // Gets the body of the request from the "Attachment" of the Data Record.
            for(Attachment att : [SELECT Name, Body FROM Attachment WHERE ParentId = :dr.Id LIMIT 1]) {
                if(att.Name.endsWithIgnoreCase('.txt')){
                	content = att.Body.toString();
                }else{
                	content = EncodingUtil.base64Encode(att.Body);
                }
                break;
            }

            if(content <> null) {
                GRAXCloud.sendDataRecordToGRAX('', content, dr);
                dataRecords2Up.add(dr);
            }
        }
        
        if(dataRecords2Up.size() > 0){
        	update dataRecords2Up;
        }
    }

    global void finish(Database.BatchableContext BC) {
        if(this.isExecuteNow && this.isArchive) {
            GRAXBatchToDeleteBackedUpData batchToDeleteBackedUpData = new GRAXBatchToDeleteBackedUpData();
            batchToDeleteBackedUpData.currentJobId = this.currentJobId;

            Database.executebatch(batchToDeleteBackedUpData, 1000);
        }
    }
}