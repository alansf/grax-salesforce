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
        Account acc = new Account(Name='TestAccount');
        insert acc;

        Account pacc = new Account(Name='TestAccount2', ParentId=acc.Id);
        insert pacc;

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

        Test.startTest();

        GRAXBatchToProcessSchedJob b = new GRAXBatchToProcessSchedJob(gsp.Id, null, 0, null);
        Id jobId = Database.executebatch(b);

        Test.stopTest();

        for(GRAX_Schedule_Process__c schedProcess : [SELECT Id, Next_Run_Date__c, Last_Run_Date__c, Status__c FROM GRAX_Schedule_Process__c WHERE Id = :gsp.Id]) {
            System.assertEquals('Completed', schedProcess.Status__c);
        }

        System.assertEquals(2, [SELECT Id FROM GRAX_Data_Record_Id__c].size());
    }

    @isTest
    static void GRAXBatchToProcessSchedJobTest2() {
        Account acc = new Account(Name='TestAccount');
        insert acc;

        Account pacc = new Account(Name='TestAccount2', ParentId=acc.Id);
        insert pacc;

        GRAX_Schedule_Process__c gsp = new GRAX_Schedule_Process__c();
        gsp.Object_Name__c = 'Account';
        gsp.Date_Field__c = 'LastModifiedDate';
        gsp.Target_Date__c = Date.today().addDays(1);
        gsp.Select_Criteria__c = 'Main Object not modified';
        gsp.Schedule_Type__c = 'Once';
        gsp.Schedule_Start_Date__c = Date.today();
        gsp.Schedule_Start_Time__c = '23:00';
        gsp.Next_Run_Date__c = Datetime.now();
        gsp.Selected_Object_Hierarchy_JSON__c = '{"uniqueKey":"Account","parentUniqueKey":null,"relatedFieldName":null,"name":"Account","childObjRelStructure":[{"uniqueKey":"Account_ChildAccounts","parentUniqueKey":"Account","relatedFieldName":"ParentId","name":"Account","childObjRelStructure":[]}]}';
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

        Test.startTest();

        Database.executebatch(new GRAXBatchToProcessSchedJob(gsp.Id, null, 0, null));

        GRAXBatchToProcessSchedJob b = new GRAXBatchToProcessSchedJob(gsp.Id, objects2Process, 1, '');
        Id jobId = Database.executebatch(b);

        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM GRAX_Data_Record_Id__c].size());
    }

}
