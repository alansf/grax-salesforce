/*****************************************************************************************
Name              : GRAXTimeMachineCtrlTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Leandro Brunner          07/02/2018
******************************************************************************************/
@isTest
public with sharing class GRAXTimeMachineCtrlTest {

    @isTest
    public static void GRAXTimeMachineCtrlTest1() {
        Profile p=[SELECT Id From Profile WHERE Name='Standard User'];
        User u2 =new User(Alias = 'newUser1' ,
                        Email ='newuser123@testorg.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'Testing',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US',
                        UserName='newuser123@testorg.com',
                        ProfileId=p.Id,
                        TimeZoneSidKey    = 'America/Los_Angeles');
        insert u2;

        Test.startTest();

        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
        dr.Status__c = 'Not Sent';
        dr.of_Times_Sent__c = 0;

        System.runAs(u2) {            
            insert dr;
        }

        PageReference pageRef = Page.GRAXTimeMachine;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', dr.Id);

        GRAXTimeMachineCtrl gtmc = new GRAXTimeMachineCtrl();
        gtmc.GRAXFileDataTest = '{"error":null,"data":{"old":[{"Status__c":"Not Sent","of_Times_Sent__c":0,"Salesforce_Object__c":"GRAX_Data_Record__c","attributes":{"url":"/services/data/v43.0/sobjects/GRAX_Data_Record__c/000000000000000","type":"GRAX_Data_Record__c"}}],"new":[{"Status__c":"Sent Successful","of_Times_Sent__c":1,"Salesforce_Object__c":"GRAX_Data_Record__c","attributes":{"url":"/services/data/v43.0/sobjects/GRAX_Data_Record__c/000000000000000","type":"GRAX_Data_Record__c"}}]},"status":"success","source":"GetFile"}';
        gtmc.fileSelect = gtmc.ParseJSON(gtmc.timeMachine);

        
        System.assertEquals(true, gtmc.getHasBackups());

        System.assert(gtmc.getFileSelectJson().length() > 2);

        pageRef.getParameters().put('fileSelected', gtmc.fileSelect.get(0).getValue());
        gtmc.changeFileSelected();

        System.assertEquals(true, gtmc.getIsFileSelected());

        Map<String, GRAXTimeMachineCtrl.MapFieldDiff> diffMap = gtmc.getDiff();

        System.debug(JSON.serializePretty(diffMap));

        System.assert(diffMap.size() > 3);

        for(String fieldName : diffMap.keySet()) {
            GRAXTimeMachineCtrl.MapFieldDiff diff = diffMap.get(fieldName);
            
            if(fieldName == 'Status__c' || fieldName == 'of_Times_Sent__c') {
                System.assert(diff.isDifferent);
            }

            if(fieldName == 'GRAX_Data_Record__c') {
                System.assert(!diff.isDifferent);
            }
            
            System.assert(diff.isDifferent == (diff.oldValue <> diff.newValue));
        }

        gtmc.updateToThisVersion();

        for(GRAX_Data_Record__c r : [SELECT Status__c, of_Times_Sent__c FROM GRAX_Data_Record__c WHERE Id = :dr.Id]) {
            System.assertEquals('Sent Successful', r.Status__c);
            System.assertEquals(1, r.of_Times_Sent__c);
        }

        gtmc.restoreToOldVersion();

        for(GRAX_Data_Record__c r : [SELECT Status__c, of_Times_Sent__c FROM GRAX_Data_Record__c WHERE Id = :dr.Id]) {
            System.assertEquals('Not Sent', r.Status__c);
            System.assertEquals(0, r.of_Times_Sent__c);
        }

        Test.stopTest();
        
    }

}