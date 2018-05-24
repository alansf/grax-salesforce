/*****************************************************************************************
Name              : GRAXSchedulerToDeleteBackedUpData
Description       : This Schedule process deletes all the SFDC records that have been successfully sent to the GRAX Cloud
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Ariel Yankelevich       05/10/2018           David Mackey        GRAX Archiving -- Salesforce Delete (https://app.asana.com/0/326600806074978/628249897265165/f)
******************************************************************************************/
global class GRAXSchedulerToDeleteBackedUpData implements Schedulable {
	global void execute(SchedulableContext sc) {
		GRAXBatchToDeleteBackedUpData b = new GRAXBatchToDeleteBackedUpData();
        Database.executebatch(b, 1000);
    }
}