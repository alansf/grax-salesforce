/*****************************************************************************************
Name              : GRAXSchedulerToProcessSchedJobs
Description       : This Schedule process finds the Schedule Process jobs that are supposed to run at this moment or did not execute in the previous Schedule execution
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Ariel Yankelevich       05/08/2018           David Mackey        GRAX Audit Trail Process (https://app.asana.com/0/326600806074978/633149554508926/f)
******************************************************************************************/
global class GRAXSchedulerToProcessSchedJobs implements Schedulable {
	global void execute(SchedulableContext sc) {
    	List<GRAX_Schedule_Process__c> schedProcesses2Up = new List<GRAX_Schedule_Process__c>();
       
		// Find any Schedule Process Job that is supposed to run at the current GMT time, 
		// or that it hasn't been executed on the previous Schedule run and it's not currently executing
		for(GRAX_Schedule_Process__c schedProcess : [SELECT Id, Status__c FROM GRAX_Schedule_Process__c WHERE Next_Run_Date__c <=: System.now() AND Status__c <> 'Running']){
            GRAXBatchToProcessSchedJob b = new GRAXBatchToProcessSchedJob(schedProcess.Id, null, 0, null, null);
            
            try{
				// Check if the call to "executebatch" failed to acquire an Apex flex queue lock
                Id jobId = Database.executebatch(b, 1000);
                schedProcess.Status__c = 'Running';
            }catch(System.AsyncException e){
                schedProcess.Status__c = 'Error';
            }
            
            schedProcesses2Up.add(schedProcess);
       	}        
        
        if(schedProcesses2Up.size() > 0){
            update schedProcesses2Up;
        }
   	}
}