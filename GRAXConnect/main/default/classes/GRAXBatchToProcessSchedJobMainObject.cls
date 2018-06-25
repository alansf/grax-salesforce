/*****************************************************************************************
Name              : GRAXBatchToProcessSchedJobMainObject
Description       : This batch process executes a GRAX Schedule Process job, calling itself object by object as defined in the selected hierarchy
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Ariel Yankelevich       06/18/2018           David Mackey        Backup and Restore Notes & Attachments (https://app.asana.com/0/326600806074978/692982800286805/f)
******************************************************************************************/

global class GRAXBatchToProcessSchedJobMainObject implements Database.Batchable<sObject>, Database.Stateful{
    public GRAXBatchToProcessSchedJob mainBatchProcess;
	
    public GRAXBatchToProcessSchedJobMainObject(String jobId, Boolean isExecuteNow){
        mainBatchProcess = new GRAXBatchToProcessSchedJob(jobId, null, 0, null, isExecuteNow);
    }
    
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(mainBatchProcess.query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
    	mainBatchProcess.executeMethod(scope);
    }
    
    global void finish(Database.BatchableContext BC){
    	mainBatchProcess.finishMethod();
    }
}