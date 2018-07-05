/*****************************************************************************************
Name              : GRAXBatchToProcessSchedJobTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner    05/23/2018                David Mackey        "Restore" Button for Backup/Archive (https://app.asana.com/0/326600806074978/665432711419635/f)
******************************************************************************************/
@isTest
public class GRAXBatchToProcessSchedJobTest {

    @isTest
    static void GRAXBatchToProcessSchedJobTest1() {
        GRAXQuery__c gq = new GRAXQuery__c();
        gq.ObjectName__c = 'GRAXQuery__c';
        insert gq;

        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'GRAXQuery__c';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"GRAXQuery__c","parentUniqueKey":null,"relatedFieldName":null,"name":"GRAXQuery__c","childObjRelStructure":[]}';
        gsp.Archive__c = false;
        insert gsp;

        GRAXUnitTest.SingleRequestMock fakeResponse = new GRAXUnitTest.SingleRequestMock(200, '{"message": "Test successful"}', 'http://test.grax.io/applications/neo4j/configure', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        GRAXBatchToProcessSchedJob b = new GRAXBatchToProcessSchedJob(gsp.Id, null, 0, null, true);

        Test.startTest();

        Id jobId = Database.executebatch(b, 10);

        Test.stopTest();

        for(GRAX_Schedule_Process__c schedProcess : [SELECT Id, Next_Run_Date__c, Last_Run_Date__c, Status__c FROM GRAX_Schedule_Process__c WHERE Id = :gsp.Id]) {
            System.assertEquals('Completed', schedProcess.Status__c);
        }

        System.assertEquals(1, [SELECT Id FROM GRAX_Data_Record_Id__c].size());
    }

    @isTest
    static void GRAXBatchToProcessSchedJobTest2() {
        GRAXQuery__c gq = new GRAXQuery__c();
        gq.ObjectName__c = 'GRAXQuery__c';
        insert gq;

        Attachment att = new Attachment();   	
    	att.Name = 'Test';
    	att.body = Blob.valueOf('Test');
        att.parentId = gq.id;
        insert att;

        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'GRAXQuery__c';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"GRAXQuery__c","parentUniqueKey":null,"relatedFieldName":null,"name":"GRAXQuery__c","childObjRelStructure":[{"uniqueKey":"GRAXQuery__c_Attachments","parentUniqueKey":"GRAXQuery__c","relatedFieldName":"ParentId","name":"Attachment","childObjRelStructure":[]}]}';
        gsp.Archive__c = true;
        insert gsp;

        List<GRAXBackupCtrl.ObjRelStructure> objects2Process = new List<GRAXBackupCtrl.ObjRelStructure>();
        GRAXBackupCtrl.ObjRelStructure rootSObj = (GRAXBackupCtrl.ObjRelStructure)JSON.deserialize(gsp.Selected_Object_Hierarchy_JSON__c, GRAXBackupCtrl.ObjRelStructure.class);

        objects2Process.add(rootSObj);

        Integer i = 0;
        while(objects2Process.size() > 0 && i < objects2Process.size()){
            GRAXBackupCtrl.ObjRelStructure sObjRelStruc = objects2Process[i];
            objects2Process.addAll(sObjRelStruc.childObjRelStructure);
            i++;
        }

        GRAXUnitTest.SingleRequestMock fakeResponse = new GRAXUnitTest.SingleRequestMock(200, '{"message": "Test successful"}', 'http://test.grax.io/applications/neo4j/configure', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        GRAXBatchToProcessSchedJobMainObject b1 = new GRAXBatchToProcessSchedJobMainObject(gsp.Id, true);
        GRAXBatchToProcessSchedJob b2 = new GRAXBatchToProcessSchedJob(gsp.Id, objects2Process, 1, '', true);

        Test.startTest();

        Database.executebatch(b1, 10);
        Database.executebatch(b2, 20);

        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM GRAX_Data_Record_Id__c].size());
    }

    @isTest
    static void GRAXBatchToProcessSchedJobTestAttachmentArchive() {
        GRAXQuery__c gq = new GRAXQuery__c();
        gq.ObjectName__c = 'GRAXQuery__c';
        insert gq;

        Attachment att = new Attachment();   	
    	att.Name = 'Test';
    	att.body = Blob.valueOf('Test');
        att.parentId = gq.id;
        insert att;

        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'GRAXQuery__c';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"GRAXQuery__c_Attachments","parentUniqueKey":"GRAXQuery__c","relatedFieldName":"ParentId","name":"Attachment","childObjRelStructure":[]}';
        gsp.Archive__c = true;
        insert gsp;

        GRAXUnitTest.SingleRequestMock fakeResponse = new GRAXUnitTest.SingleRequestMock(200, '{"message": "Test successful"}', 'http://test.grax.io/applications/neo4j/configure', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        GRAXBatchToProcessSchedJob b = new GRAXBatchToProcessSchedJob(gsp.Id, null, 0, null, true);

        Test.startTest();
        
        Id jobId = Database.executebatch(b, 10);

        Test.stopTest();

        Attachment att2 = [SELECT Id, Body FROM Attachment ORDER BY CreatedDate DESC LIMIT 1];
        String att2BodyString = att2.Body.toString();

        System.assertNotEquals(null, att2);

        System.assert(att2BodyString.contains('GRAX_Data_Record_Id'));
        System.assert(att2BodyString.contains('Ready to Process'));
    }

    @isTest
    static void GRAXBatchToProcessSchedJobExecuteNowTest() {
        Datetime now = Datetime.now();
        
        GRAXQuery__c gq = new GRAXQuery__c();
        gq.ObjectName__c = 'GRAXQuery__c';
        insert gq;

        Attachment att = new Attachment();   	
    	att.Name = 'Test';
    	att.body = Blob.valueOf('Test');
        att.parentId = gq.id;
        insert att;

        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'GRAXQuery__c';
        gsp.Date_Field__c = 'CreatedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = now;
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"GRAXQuery__c","parentUniqueKey":null,"relatedFieldName":null,"name":"GRAXQuery__c","childObjRelStructure":[]}';
        gsp.Archive__c = true;
        insert gsp;

        GRAXUnitTest.SingleRequestMock fakeResponse = new GRAXUnitTest.SingleRequestMock(200, 'OK', '{"message": "Test successful"}', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        GRAXBatchToProcessSchedJob b = new GRAXBatchToProcessSchedJob(gsp.Id, null, 0, null, true);

        Test.startTest();
        
        Id jobId = Database.executebatch(b, 10);

        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM GRAX_Schedule_Process__c WHERE Id = :gsp.Id AND Next_Run_Date__c = :now].size());
        System.assertEquals(1, [SELECT Id FROM GRAX_Data_Record_Id__c WHERE Status__c = 'Successfully Deleted'].size());
        System.assertEquals(0, [SELECT Id FROM GRAXQuery__c WHERE Id = :gq.Id].size());
    }

}
