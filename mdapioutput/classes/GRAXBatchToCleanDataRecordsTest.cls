/*****************************************************************************************
Name              : GRAXBatchToCleanDataRecordsTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
******************************************************************************************/
@isTest
private class GRAXBatchToCleanDataRecordsTest {
    @isTest(seeAllData = false)
    static void GRAXBatchToCleanDataRecordsTest() {

        // To delete
        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'GRAXQuery__c';
        gsp.Date_Field__c = 'CreatedDate';
        gsp.Target_Date__c = Date.today().addDays(-3);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Archive__c = true;
        insert gsp;

        GRAX_Archive_Process__c archiveProc = new GRAX_Archive_Process__c();
        archiveProc.GRAX_Schedule_Process__c = gsp.Id;
        archiveProc.Async_Records_Successfully_Sent__c = 0;
        archiveProc.Async_Records_to_Process__c = 0;
        archiveProc.Records_Successfully_Sent__c = 2;
        archiveProc.Records_To_Process__c = 0;
        insert archiveProc;

        // To delete
        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
        dr.Salesforce_Object__c = 'GRAXQuery__c';
        dr.Status__c = 'Sent Successful';
        dr.of_Times_Sent__c = 1;
        dr.Error_Message__c = null;
        //dr.GRAX_Archive_Process__c = archiveProc.Id;
        dr.Last_Sent_Date__c = Date.today().addDays(-3);

        // To delete
        GRAX_Data_Record__c dr2 = new GRAX_Data_Record__c();
        dr2.Salesforce_Object__c = 'GRAXQuery__c';
        dr2.Status__c = 'Sent Successful';
        dr2.of_Times_Sent__c = 1;
        dr2.Error_Message__c = null;
        dr2.GRAX_Archive_Process__c = archiveProc.Id;
        dr2.Last_Sent_Date__c = Date.today().addDays(-2);

        GRAX_Data_Record__c dr3 = new GRAX_Data_Record__c();
        dr3.Salesforce_Object__c = 'GRAXQuery__c';
        dr3.Status__c = 'Sent Successful';
        dr3.of_Times_Sent__c = 1;
        dr3.Error_Message__c = null;
        dr3.GRAX_Archive_Process__c = archiveProc.Id;
        dr3.Last_Sent_Date__c = Date.today();

		insert new List<GRAX_Data_Record__c> { dr, dr2, dr3 };

        // To delete
        GRAX_Data_Record_Id__c dri = new GRAX_Data_Record_Id__c();
        dri.GRAX_Data_Record__c = dr.Id;

        // To delete
        GRAX_Data_Record_Id__c dri2 = new GRAX_Data_Record_Id__c();
        dri2.GRAX_Data_Record__c = dr2.Id;

        GRAX_Data_Record_Id__c dri3 = new GRAX_Data_Record_Id__c();
        dri3.GRAX_Data_Record__c = dr3.Id;

        insert new List<GRAX_Data_Record_Id__c> { dri, dri2, dri3 };

        Test.startTest();
        database.executebatch(new GRAXBatchToCleanDataRecords(0));
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM GRAX_Data_Record__c WHERE Id IN : new List<GRAX_Data_Record__c>{dr, dr2, dr3}].size());
        System.assertEquals(1, [SELECT Id FROM GRAX_Data_Record_Id__c WHERE Id IN : new List<GRAX_Data_Record_Id__c>{dri, dri2, dri3}].size());
        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Id IN : new List<GRAX_Archive_Process__c>{archiveProc}].size());
    }
}
