/*****************************************************************************************
Name              : GRAXRestoreCtrlTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner    05/22/2018                David Mackey        "Restore" Button for Backup/Archive (https://app.asana.com/0/326600806074978/665432711419635/f)
******************************************************************************************/
@isTest
public class GRAXRestoreCtrlTest {

    @testSetup static void setup() {
        Account acc = new Account(Name='TestAccount');
        insert acc;

        Account pacc = new Account(Name='TestAccount2', ParentId=acc.Id);
        insert pacc;
    }

    @isTest
    static void GRAXRestoreCtrlConstructorTest() {
        PageReference pageRef = Page.GRAXRestore;
        Test.setCurrentPage(pageRef);

        Id accId;

        for(Account acc : [SELECT Id FROM Account WHERE Name = 'TestAccount2']) {
            accId = acc.Id;
        }

        pageRef.getParameters().put('Id', String.valueOf(accId));

        GRAXRestoreCtrl grc = new GRAXRestoreCtrl();

        System.assertEquals('', grc.objToQuery);
        System.assertNotEquals(null, grc.fieldMap);
        System.assertNotEquals(null, grc.sObjectMap);
        System.assertNotEquals(null, grc.tableRecords);
        
        System.assertNotEquals(null, grc.parentId);
        System.assertEquals(accId, grc.parentId);
        System.assertEquals(accId.getSObjectType().getDescribe().getName(), grc.parentType);
    }

    @isTest
    static void changeObjToQueryTest() {
        PageReference pageRef = Page.GRAXRestore;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', '001J0000020re5wIAA'); // Account

        GRAXRestoreCtrl grc = new GRAXRestoreCtrl();

        grc.parentType = 'Account';
        
        String relatedJson = grc.getRelatedJSON();

        System.assertNotEquals(0, grc.childRelatedMap.size());
        System.assertNotEquals('[]', relatedJson);

        for(String i: grc.childRelatedMap.keySet()) {
            pageRef.getParameters().put('objToQueryValue', i);
            grc.changeObjToQuery();

            System.assertEquals(grc.childRelatedMap.get(i).name, grc.objToQuery);
            System.assertEquals(grc.childRelatedMap.get(i).value, grc.relToQuery);
        }

        System.assertNotEquals(0, grc.getSObjectFields().size());
        System.assertNotEquals('[]', grc.getFieldsJSON());
    }

    @isTest
    static void updateDataTableTest() {
        PageReference pageRef = Page.GRAXRestore;
        Test.setCurrentPage(pageRef);

        Id accId;
        String accName;

        for(Account acc : [SELECT Id, Name, OwnerId FROM Account WHERE Name = 'TestAccount']) {
            accId = acc.Id;
            accName = acc.Name;
        }

        pageRef.getParameters().put('Id', String.valueOf(accId));

        GRAXRestoreCtrl grc = new GRAXRestoreCtrl();

        pageRef.getParameters().put('selectedFields', 'Name');

        String responseData = '{"status":"success","data":[{"Id":"' + String.valueOf(accId) + '","Name":"' + accName + '"}],"message":"queryBackup"}';

        GRAXUnitTest.SingleRequestMock fakeResponse = new GRAXUnitTest.SingleRequestMock(200, 'OK', responseData, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        grc.updateDataTable();
        Test.stopTest();

        System.assertEquals(true, grc.getIsFieldSelected());
        System.assertEquals(false, grc.getIsTableRecordsEmpty());

        for(SObject so : grc.sObjectMap.values()) {
            System.assertEquals(accId, so.get('Id'));
            System.assertEquals(accName, so.get('Name'));
        }
    }

    @isTest
    static void saveSObjectToRestoreTest() {
        PageReference pageRef = Page.GRAXRestore;
        Test.setCurrentPage(pageRef);

        Id accId;
        Id paccID;
        Id ownId;
        String accName;

        for(Account acc : [SELECT Id, Name, ParentId, OwnerId FROM Account WHERE Name = 'TestAccount2']) {
            accId = acc.Id;
            paccID = acc.ParentId;
            accName = acc.Name;
            ownId = acc.OwnerId;
        }

        pageRef.getParameters().put('Id', String.valueOf(accId));

        GRAXRestoreCtrl grc = new GRAXRestoreCtrl();

        grc.objToQuery = 'Account';
        grc.updateSObjectFields();

        pageRef.getParameters().put('soToRestore', String.valueOf(accId));

        String responseData = '{"status":"success","data":[{"Id":"' + String.valueOf(accId) + '","Name":"' + accName + '","ParentId":"' + String.valueOf(paccID) + '","Description": "Simple description.","OwnerId":"' + String.valueOf(ownId) + '"}],"message":"queryBackup"}';

        GRAXUnitTest.SingleRequestMock fakeResponse = new GRAXUnitTest.SingleRequestMock(200, 'OK', responseData, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Test.startTest();
        grc.changeSObjectToRestore();
        Test.stopTest();

        System.assertNotEquals(null, grc.sobjectToRestore);
        System.assertEquals(paccID, grc.sobjectToRestore.get('ParentId'));
        System.assertEquals('Simple description.', grc.sobjectToRestore.get('Description'));

        grc.sobjectToRestore.put('Description', 'The Account Description');
        grc.saveSObjectToRestore();

        System.assertEquals(false, Apexpages.hasMessages());
        System.assertEquals('The Account Description', grc.sobjectToRestore.get('Description'));
        System.assertNotEquals(null, grc.sobjectToRestore.Id);
    }

    @isTest
    static void getItemsTest() {
        GRAXRestoreCtrl grc = new GRAXRestoreCtrl();

        Test.startTest();

        System.assertNotEquals(Schema.getGlobalDescribe().size(), grc.getItems().size() - 1);

        Test.stopTest();        
    }

}
