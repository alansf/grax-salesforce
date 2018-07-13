/*****************************************************************************************
Name              : GRAXBatchToCleanDataRecords
Description       : Clean records that have been sent correctly and are more than 48 hours old.
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       04/17/2018             David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
******************************************************************************************/
global class GRAXBatchToCleanDataRecords implements Database.Batchable<sObject> {
    private Map<String, String> queryByObject = new Map<String, String>{
        'GRAX_Data_Record__c' => 'SELECT Id FROM GRAX_Data_Record__c WHERE Status__c = \'Sent Successful\' AND Last_Sent_Date__c < LAST_N_DAYS:2 AND (GRAX_Archive_Process__c = null OR GRAX_Archive_Process__r.Status__c = \'Ready to Delete\')',
        'GRAX_Data_Record_Id__c' => 'SELECT Id FROM GRAX_Data_Record_Id__c WHERE GRAX_Data_Record__r.Status__c = \'Sent Successful\' AND GRAX_Data_Record__r.Last_Sent_Date__c < LAST_N_DAYS:2 AND (GRAX_Data_Record__r.GRAX_Archive_Process__c = null OR GRAX_Data_Record__r.GRAX_Archive_Process__r.Status__c = \'Ready to Delete\')',
        'GRAX_Archive_Process__c' => 'SELECT Id FROM GRAX_Archive_Process__c WHERE Status__c = \'Ready to Delete\''
    };
    private List<String> objects2Execute = new List<String>{'GRAX_Data_Record_Id__c','GRAX_Data_Record__c','GRAX_Archive_Process__c'};
    private Integer currentIndex = 0;
    public String query = '';
    
    public GRAXBatchToCleanDataRecords(Integer currentIndex){
        this.currentIndex = currentIndex;
        this.query = queryByObject.get(objects2Execute[currentIndex]);
    }
    
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        delete scope;
        Database.emptyRecycleBin(scope);
    }

    global void finish(Database.BatchableContext BC){
        if(currentIndex < objects2Execute.size() - 1){
            currentIndex++;
            GRAXBatchToCleanDataRecords b = new GRAXBatchToCleanDataRecords(currentIndex);
            database.executebatch(b, 1000);
        }
    }
}