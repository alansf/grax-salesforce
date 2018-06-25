/*****************************************************************************************
Name              : GRAXDataRecordTriggerTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner    06/07/2018
******************************************************************************************/
@isTest
public with sharing class GRAXDataRecordTriggerTest {
    
    @isTest
    public static void rollUpTotalRecordsToProcessTest() {
        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'Account';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"Account","parentUniqueKey":null,"relatedFieldName":null,"name":"Account","childObjRelStructure":[]}';
        gsp.Archive__c = false;
        insert gsp;

        GRAX_Archive_Process__c ap = new GRAX_Archive_Process__c(
            Async_Records_Successfully_Sent__c = 0,
            Async_Records_to_Process__c=0,
            Records_Successfully_Sent__c=0,
            Records_To_Process__c=0,
            GRAX_Schedule_Process__c=gsp.Id
        );
        insert ap;

        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
        dr.Status__c = 'Not Sent';
        dr.of_Times_Sent__c = 0;
        dr.GRAX_Archive_Process__c = ap.Id;
        insert dr;

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Records_To_Process__c = 1].size());

        delete dr;

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Records_To_Process__c = 0].size());

        undelete dr;

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Records_To_Process__c = 1].size());
    }

    @isTest
    public static void rollUpTotalRecordsSuccessfullySentTest() {
        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'Account';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"Account","parentUniqueKey":null,"relatedFieldName":null,"name":"Account","childObjRelStructure":[]}';
        gsp.Archive__c = false;
        insert gsp;

        GRAX_Archive_Process__c ap = new GRAX_Archive_Process__c(
            Async_Records_Successfully_Sent__c = 0,
            Async_Records_to_Process__c=0,
            Records_Successfully_Sent__c=0,
            Records_To_Process__c=0,
            GRAX_Schedule_Process__c=gsp.Id
        );
        insert ap;

        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
        dr.Status__c = 'Not Sent';
        dr.GRAX_Archive_Process__c = ap.Id;
        insert dr;

        dr.Status__c = 'Sent Successful';
        update dr;

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Records_Successfully_Sent__c = 1].size());

        dr.Status__c = 'Error';
        update dr;

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Records_Successfully_Sent__c = 0].size());
    }

    @isTest
    public static void rollUpTotalAsyncRecordsToProcessTest() {
        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'Attachment';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"Account_Attachments","parentUniqueKey":"Account","relatedFieldName":"ParentId","name":"Attachment","childObjRelStructure":[]}';
        gsp.Archive__c = true;
        insert gsp;

        GRAX_Archive_Process__c ap = new GRAX_Archive_Process__c(
            Async_Records_Successfully_Sent__c=0,
            Async_Records_to_Process__c=0,
            Records_Successfully_Sent__c=0,
            Records_To_Process__c=0,
            GRAX_Schedule_Process__c=gsp.Id
        );
        insert ap;

        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
        dr.Status__c = 'Not Sent';
        dr.of_Times_Sent__c = 0;
        dr.GRAX_Archive_Process__c = ap.Id;
        dr.Salesforce_Object__c = 'Attachment';
        insert dr;

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Async_Records_to_Process__c = 1].size());

        delete dr;

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Async_Records_to_Process__c = 0].size());

        undelete dr;

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Async_Records_to_Process__c = 1].size());
    }

    @isTest
    public static void rollUpTotalAsyncRecordsSuccessfullySentTest() {
        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'Attachment';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"Account_Attachments","parentUniqueKey":"Account","relatedFieldName":"ParentId","name":"Attachment","childObjRelStructure":[]}';
        gsp.Archive__c = true;
        insert gsp;

        GRAX_Archive_Process__c ap = new GRAX_Archive_Process__c(
            Async_Records_Successfully_Sent__c = 0,
            Async_Records_to_Process__c=0,
            Records_Successfully_Sent__c=0,
            Records_To_Process__c=0,
            GRAX_Schedule_Process__c=gsp.Id
        );
        insert ap;

        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
        dr.Status__c = 'Not Sent';
        dr.of_Times_Sent__c = 0;
        dr.GRAX_Archive_Process__c = ap.Id;
        dr.Salesforce_Object__c = 'Attachment';
        insert dr;

        GRAX_Data_Record_Id__c dri = new GRAX_Data_Record_Id__c();
        dri.GRAX_Data_Record__c = dr.Id;
        insert dri;

        dri.Status__c = 'Sent to GRAX';
        update dri;
        

        System.assertEquals(1, [SELECT Id FROM GRAX_Archive_Process__c WHERE Async_Records_Successfully_Sent__c = 1].size());
    }
    
}
