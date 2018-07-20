/*****************************************************************************************
Name              : GRAXBackupCtrlTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner    05/10/2018                David Mackey        "Restore" Button for Backup/Archive (https://app.asana.com/0/326600806074978/665432711419635/f)
******************************************************************************************/
@isTest
public class GRAXBackupCtrlTest {

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
            gsp.Archive__c = false;

            gspList.add(gsp);
        }

        insert gspList;

        for(GRAX_Schedule_Process__c gsp : gspList) {
            GRAXUtils.setSelectionJSON(gsp.Id, '{"uniqueKey":"' + gsp.Object_Name__c + '","parentUniqueKey":null,"relatedFieldName":null,"name":"' + gsp.Object_Name__c + '","childObjRelStructure":[]}');
        }
    }

    @isTest
    static void GRAXBackupCtrlConstructorTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        System.assertEquals(UserInfo.getTimeZone().getID(), gbc.userTimeZone);
        System.assertEquals('', gbc.selectedObject);
        System.assertEquals('LastModifiedDate', gbc.sObjectDateFieldDefault);
        System.assertEquals('Main Object not modified', gbc.criteria);
        System.assertEquals(false, gbc.archive);
        System.assertEquals(null, gbc.gsp.Id);
        System.assertEquals(false, gbc.archive);
        System.assertEquals(gbc.scheduledProcessMap.values(), gbc.getScheduledProcesses());
    }

    @isTest
    static void changeSelectedObjectTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('selectedObjectValue', 'Account');
        
        Test.startTest();
        gbc.changeSelectedObject();
        Test.stopTest();

        System.assertEquals(gbc.selectedObject, 'Account');
        System.assertEquals(gbc.sObjectDateField, gbc.sObjectDateFieldDefault);
    }

    @isTest
    static void saveScheduledProcessTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        gbc.scheduledProcessType = 'Hierarchy';
        gbc.selectedObject = 'Account';
        gbc.sObjectDateField = gbc.sObjectDateFieldDefault;
        gbc.targetDate = '12/25/2018';
        gbc.schedule = 'Monthly';
        gbc.scheduleStartDate = '12/31/2018';
        gbc.scheduleStartTime = '23:00';
        gbc.objectJSON = '{}';
        gbc.archive = true;

        Integer prevScheduledProcessMapsize = gbc.scheduledProcessMap.size();

        Test.startTest();
        gbc.saveScheduledProcess();
        Test.stopTest();

        System.assertEquals(gbc.selectedObject, '');
        System.assertNotEquals(gbc.scheduledProcessMap, null);
        System.assertNotEquals(gbc.scheduledProcessMap.size(), prevScheduledProcessMapsize);

        System.assertEquals([
            SELECT CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name IN :new List<String>{ 'GRAXSchedulerToProcessSchedJobs', 'GRAXSchedulerToDeleteBackedUpData' }
        ].size(), 2);
    }

    @isTest
    static void saveScheduledProcessTest2() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        gbc.filterCriteriaType = 'Report';
        gbc.scheduledProcessType = 'Hierarchy';
        gbc.selectedObject = 'Account';
        gbc.sObjectDateField = gbc.sObjectDateFieldDefault;
        gbc.targetReport = '00OU0000000aYlZ';
        gbc.schedule = 'Monthly';
        gbc.scheduleStartDate = '12/31/2018';
        gbc.scheduleStartTime = '23:00';
        gbc.objectJSON = '{}';
        gbc.archive = false;

        Integer prevScheduledProcessMapsize = gbc.scheduledProcessMap.size();

        Test.startTest();
        gbc.saveScheduledProcess();
        Test.stopTest();

        System.assertEquals(gbc.selectedObject, '');
        System.assertNotEquals(gbc.scheduledProcessMap, null);
        System.assertNotEquals(gbc.scheduledProcessMap.size(), prevScheduledProcessMapsize);
    }

    @isTest
    static void saveScheduledProcessTest3() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        List<Object> objectList = (List<Object>)JSON.deserializeUntyped(gbc.getItemsJSON());

        System.assertEquals(gbc.getItems().size() - 1, objectList.size());

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        gbc.scheduledProcessType = 'Multi-Object';
        gbc.schedule = 'Monthly';
        gbc.scheduleStartDate = '12/31/2018';
        gbc.scheduleStartTime = '23:00';
        gbc.objectJSON = '[]';

        Integer prevMultiObjectBackupMapSize = gbc.multiObjectBackupMap.size();

        Test.startTest();
        gbc.saveScheduledProcess();
        Test.stopTest();

        System.assertEquals(gbc.selectedObject, '');
        System.assertNotEquals(gbc.multiObjectBackupMap, null);
        System.assertNotEquals(gbc.multiObjectBackupMap.size(), prevMultiObjectBackupMapSize);
    }

    @isTest
    static void getSObjectDateFieldsTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        gbc.selectedObject = 'Account';

        Test.startTest();
        List<SelectOption> sObjectDateFields = gbc.getSObjectDateFields();
        Test.stopTest();

        System.assertNotEquals(sObjectDateFields, null);
        System.assertNotEquals(sObjectDateFields.size(), 0);
    }

    @isTest
    static void deleteScheduledProcessTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        gbc.updateScheduledProcessMap();

        Integer prevScheduledProcessMapsize = gbc.scheduledProcessMap.size();
        Id idToDelete;

        Test.startTest();

        for(GRAX_Schedule_Process__c gsp : [SELECT Id FROM GRAX_Schedule_Process__c LIMIT 1]) {
            idToDelete = gsp.Id;
            pageRef.getParameters().put('spId', idToDelete);
            gbc.deleteScheduledProcess();
        }

        Test.stopTest();

        System.assertEquals(false, gbc.scheduledProcessMap.containsKey(idToDelete));
        System.assertNotEquals(gbc.scheduledProcessMap.size(), prevScheduledProcessMapsize);
        System.assertEquals([SELECT Id FROM GRAX_Schedule_Process__c WHERE Id = :idToDelete LIMIT 1].size(), 0);
    }

    @isTest
    static void selectScheduledProcessTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        gbc.updateScheduledProcessMap();

        Test.startTest();
        
        for(GRAXBackupCtrl.ScheduledProcess sp : gbc.scheduledProcessMap.values()) {
            GRAX_Schedule_Process__c gsp = sp.GRAXScheduleProcess;

            pageRef.getParameters().put('spId', gsp.Id);
            gbc.selectScheduledProcess();

            System.assertEquals(gbc.selectedObject, gsp.Object_Name__c);
            System.assertEquals(gbc.sObjectDateField, gsp.Date_Field__c);
            System.assertEquals(gbc.targetDate, String.valueOf(gsp.Target_Date__c));
            System.assertEquals(gbc.criteria, gsp.Select_Criteria__c);
            System.assertEquals(gbc.schedule, gsp.Schedule_Type__c);
            System.assertEquals(gbc.scheduleStartDate, gsp.Schedule_Start_Date__c.format());
            System.assertEquals(gbc.scheduleStartTime, gsp.Schedule_Start_Time__c);
            System.assertEquals(gbc.objectJSON, GRAXUtils.getSelectionJSON(gsp.Id));
            System.assertEquals(gbc.archive, gsp.Archive__c);
        }

        Test.stopTest();
    }

    @isTest
    static void getRelStructureTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        System.assertEquals('{}', gbc.getRelStructure());

        gbc.selectedObject = 'Event';

        Test.startTest();

        System.assertNotEquals('{}', gbc.getRelStructure());

        Test.stopTest();        
    }

    @isTest
    static void getItemsTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        Test.startTest();

        System.assertNotEquals(Schema.getGlobalDescribe().size(), gbc.getItems().size() - 1);

        Test.stopTest();        
    }

    @isTest
    static void getReportsJSONTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        Test.startTest();

        System.assertNotEquals(null, gbc.getReportsJSON());

        Test.stopTest();        
    }

    @isTest
    static void cleanFormDataHandlerTest() {
        GRAXBackupCtrl gbc = new GRAXBackupCtrl();

        gbc.filterCriteriaType = 'Report';
        gbc.scheduledProcessType = 'Hierarchy';
        gbc.selectedObject = 'Account';
        gbc.sObjectDateField = gbc.sObjectDateFieldDefault;
        gbc.targetReport = '00OU0000000aYlZ';
        gbc.schedule = 'Monthly';
        gbc.scheduleStartDate = '12/31/2018';
        gbc.scheduleStartTime = '23:00';
        gbc.objectJSON = '{}';
        gbc.archive = false;

        PageReference pageRef = Page.GRAXBackup;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        gbc.cleanFormDataHandler();

        System.assertEquals(null, gbc.gsp.Id);
        System.assertEquals('', gbc.scheduledProcessType);
        System.assertEquals('', gbc.selectedObject);
        System.assertEquals('Date', gbc.filterCriteriaType);
        System.assertEquals(null, gbc.targetDate);
        System.assertEquals('', gbc.targetReport);
        System.assertEquals('Main Object not modified', gbc.criteria);
        System.assertEquals(null, gbc.schedule);
        System.assertEquals(null, gbc.scheduleStartDate);
        System.assertEquals(null, gbc.scheduleStartTime);
        System.assertEquals(null, gbc.objectJSON);
        System.assertEquals(false, gbc.archive);
        System.assertEquals(null, gbc.selectionAttachment);

        Test.stopTest();        
    }
}
