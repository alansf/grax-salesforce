/*****************************************************************************************
Name              : GRAXSchedulerToProcessSchedJobsTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner    05/23/2018                David Mackey        "Restore" Button for Backup/Archive (https://app.asana.com/0/326600806074978/665432711419635/f)
******************************************************************************************/
@isTest
public class GRAXSchedulerToProcessSchedJobsTest {

    @testSetup static void setup() {
        List<GRAX_Schedule_Process__c> gspList = new List<GRAX_Schedule_Process__c>();

        for(String obj : new List<String>{ 'Account', 'Opportunity', 'Case', 'Event' }) {
            GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();

            gsp.Object_Name__c = obj;
            gsp.Date_Field__c = 'LastModifiedDate';
            gsp.Target_Date__c = Date.today();
            gsp.Select_Criteria__c = 'Main Object not modified';
            gsp.Schedule_Type__c = 'Monthly';
            gsp.Schedule_Start_Date__c = Date.today();
            gsp.Schedule_Start_Time__c = '23:00';
            gsp.Next_Run_Date__c = Datetime.now();
            gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"' + obj + '","parentUniqueKey":null,"relatedFieldName":null,"name":"' + obj + '","childObjRelStructure":[]}';
            gsp.Archive__c = false;

            gspList.add(gsp);
        }

        insert gspList;
    }

    static testmethod void GRAXSchedulerToProcessSchedJobsTest() {
        Test.startTest();
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        String jobId = System.schedule('GRAXSchedulerToProcessSchedJobs', CRON_EXP, new GRAXSchedulerToProcessSchedJobs());

        Test.stopTest();

        for(GRAX_Schedule_Process__c sp : [SELECT Id, Status__c FROM GRAX_Schedule_Process__c LIMIT 4]){
            System.assert(String.isNotBlank(sp.Status__c));
       	}
    }
}
