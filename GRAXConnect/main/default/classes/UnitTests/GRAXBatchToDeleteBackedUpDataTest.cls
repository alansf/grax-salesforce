/*****************************************************************************************
Name              : GRAXBatchToDeleteBackedUpDataTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       05/24/2018             David Mackey        "Restore" Button for Backup/Archive (https://app.asana.com/0/326600806074978/665432711419635/f)
******************************************************************************************/
@isTest
public class GRAXBatchToDeleteBackedUpDataTest {

    @isTest
    static void GRAXBatchToProcessSchedJobTest1() {
        List<GRAX_Data_Record__c> drList = new List<GRAX_Data_Record__c>();

        for(Integer i=0; i < 3; i++) {
            GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
            dr.Status__c = 'Sent Successful';
            dr.of_Times_Sent__c = 1;

            drList.add(dr);
        }

        insert drList;

        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'GRAX_Data_Record__c';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"GRAX_Data_Record__c","parentUniqueKey":null,"relatedFieldName":null,"name":"GRAX_Data_Record__c","childObjRelStructure":[]}';
        gsp.Archive__c = true;
        insert gsp;

        GRAX_Archive_Process__c archiveProc = new GRAX_Archive_Process__c();
        archiveProc.GRAX_Schedule_Process__c = gsp.Id;
        archiveProc.Async_Records_Successfully_Sent__c = 0;
        archiveProc.Async_Records_to_Process__c = 0;
        archiveProc.Records_Successfully_Sent__c = 3;
        archiveProc.Records_To_Process__c = 0;
        insert archiveProc;

        for(GRAX_Data_Record__c gdr : drList) {
            GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
            dr.Salesforce_Object__c = 'GRAX_Data_Record__c';
            dr.Status__c = 'Sent Successful';
            dr.of_Times_Sent__c = 1;
            dr.Error_Message__c = null;
            dr.GRAX_Archive_Process__c = archiveProc.Id;
            insert dr;

            System.assertNotEquals(null, dr.Id);

            Attachment req_att = new Attachment();
            req_att.Name = 'request.txt';
            req_att.Body = Blob.valueOf('{}');
            req_att.ParentId = dr.Id;
            insert req_att;
            
            System.assertNotEquals(null, req_att.Id);
            
            GRAX_Data_Record_Id__c dataRecId = new GRAX_Data_Record_Id__c();
            dataRecId.SFDC_Id__c = gdr.Id;
            dataRecId.GRAX_Data_Record__c = dr.Id;
            dataRecId.Status__c = 'To be Deleted';
            
            insert dataRecId;

            System.assertNotEquals(null, dataRecId.Id);
        }

        Test.startTest();

        GRAXBatchToDeleteBackedUpData b = new GRAXBatchToDeleteBackedUpData();
        Id jobId = Database.executebatch(b);

        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Id = :archiveProc.Id AND Status__c = 'Ready to Delete' LIMIT 3].size());
        System.assertEquals(3, [SELECT Id FROM GRAX_Data_Record__c LIMIT 6].size());
    }
}
