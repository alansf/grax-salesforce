/*****************************************************************************************
Name              : GRAXBatchToCleanDataRecords
Description       : Clean records that have been sent correctly and are more than 48 hours old.
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
******************************************************************************************/
global class GRAXBatchToCleanDataRecords implements Database.Batchable<sObject> {
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM GRAX_Data_Record__c WHERE Status__c = \'Sent Successful\' AND Last_Sent_Date__c < LAST_N_DAYS:2');
    }

    global void execute(Database.BatchableContext BC, List<GRAX_Data_Record__c> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {}
}