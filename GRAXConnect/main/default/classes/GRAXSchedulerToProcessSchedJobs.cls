/*****************************************************************************************
Name              : GRAXSchedulerToProcessSchedJobs
Description       : This Schedule process finds the Schedule Process jobs that are supposed to run at this moment or did not execute in the previous Schedule execution
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Ariel Yankelevich       05/08/2018           David Mackey        GRAX Audit Trail Process (https://app.asana.com/0/326600806074978/633149554508926/f)
2. Ariel Yankelevich       07/18/2018           David Mackey        Multi-Object Backup (https://app.asana.com/0/326600806074978/743044564916005/f)
******************************************************************************************/
global class GRAXSchedulerToProcessSchedJobs implements Schedulable {
	global void execute(SchedulableContext sc) {
    	List<GRAX_Schedule_Process__c> schedProcesses2Up = new List<GRAX_Schedule_Process__c>();
       
		// Find any Schedule Process Job that is supposed to run at the current GMT time, 
		// or that it hasn't been executed on the previous Schedule run and it's not currently executing
		for(GRAX_Schedule_Process__c schedProcess : [SELECT Id, Status__c, Target_Date__c, Target_Report__c, Object_Name__c, type__c FROM GRAX_Schedule_Process__c WHERE Next_Run_Date__c <=: System.now() AND Status__c <> 'Running']){
            if(schedProcess.Target_Date__c <> null || schedProcess.type__c == 'Multi-Object') {
                GRAXBatchToProcessSchedJobMainObject b = new GRAXBatchToProcessSchedJobMainObject(schedProcess.Id, false, schedProcess.type__c == 'Multi-Object');
               
                try{
                    // Check if the call to "executebatch" failed to acquire an Apex flex queue lock
                    Id jobId = Database.executebatch(b, GRAXUtils.getBatchMaxExecutionNumber(schedProcess.Object_Name__c));
                    schedProcess.Status__c = 'Running';
                }catch(System.AsyncException e){
                    schedProcess.Status__c = 'Error';
                }
            }

            if(schedProcess.Target_Report__c <> null) {
                GRAXBatchToProcessSchedJobFromReport b = new GRAXBatchToProcessSchedJobFromReport(schedProcess.Id, null, null, false);
                
                try{
                    // Check if the call to "executebatch" failed to acquire an Apex flex queue lock
                    Id jobId = Database.executebatch(b, GRAXUtils.getBatchMaxExecutionNumber(schedProcess.Object_Name__c));
                    schedProcess.Status__c = 'Running';
                }catch(System.AsyncException e){
                    schedProcess.Status__c = 'Error';
                }
            }
            
            
            schedProcesses2Up.add(schedProcess);
       	}        
        
        if(schedProcesses2Up.size() > 0){
            update schedProcesses2Up;
        }
   	}
}