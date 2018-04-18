/*****************************************************************************************
Name              : GRAXSchedulerToResendDataRecords
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
******************************************************************************************/
global class GRAXSchedulerToResendDataRecords implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executebatch(new GRAXBatchToResendDataRecords(), 10);
   }
}
