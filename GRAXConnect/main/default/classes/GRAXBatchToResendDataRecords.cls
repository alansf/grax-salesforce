/*****************************************************************************************
Name              : GRAXBatchToResendDataRecords
Description       : Try again to do up to 5 times the Callout of the records that were not sent correctly.
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
******************************************************************************************/
global class GRAXBatchToResendDataRecords implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Salesforce_Object__c, of_Times_Sent__c FROM GRAX_Data_Record__c WHERE Status__c <> \'Sent Successful\' AND of_Times_Sent__c < 5');
    }

    global void execute(Database.BatchableContext BC, List<GRAX_Data_Record__c> scope) {
        for(GRAX_Data_Record__c dr : scope) {
            String content;

            // Gets the body of the request from the "Attachment" of the Data Record.
            for(Attachment att : [SELECT Body FROM Attachment WHERE ParentId = :dr.Id LIMIT 1]) {
                content = EncodingUtil.base64Encode(att.Body);
                break;
            }

            if(content <> null) {
                GRAXSettings gxcSettings = new GRAXSettings(dr.Salesforce_Object__c);
                GRAXCloud.calloutnowAndUpdateDataRecord(gxcSettings.ApiURL + '/applications/neo4j/configure', content, dr);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {}
}
