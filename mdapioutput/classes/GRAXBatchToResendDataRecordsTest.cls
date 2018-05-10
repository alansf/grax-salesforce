/*****************************************************************************************
Name              : GRAXBatchToResendDataRecordsTest
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
******************************************************************************************/
@isTest
private class GRAXBatchToResendDataRecordsTest {
    @isTest(seeAllData = false)
    static void GRAXBatchToResendDataRecordsTest() {
        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
		dr.Salesforce_Object__c = 'Test';
		dr.Status__c = 'Error';
		dr.of_Times_Sent__c = 4;

        GRAX_Data_Record__c dr2 = new GRAX_Data_Record__c();
		dr2.Salesforce_Object__c = 'Test';
		dr2.Status__c = 'Error';
		dr2.of_Times_Sent__c = 5;

		insert new List<GRAX_Data_Record__c> { dr, dr2 };

		Attachment att = new Attachment();
		att.Name = 'request.txt';
		att.Body = Blob.valueOf('{}');
		att.ParentId = dr.Id;

        Attachment att2 = new Attachment();
		att2.Name = 'request.txt';
		att2.Body = Blob.valueOf('{}');
		att2.ParentId = dr2.Id;

        insert new List<Attachment> { att, att2 };

        GRAXUnitTest.SingleRequestMock fakeResponse = new GRAXUnitTest.SingleRequestMock(200, '{"message": "Test successful"}', 'http://test.grax.io/applications/neo4j/configure', null);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        database.executebatch(new GRAXBatchToResendDataRecords());

        Test.stopTest();

        Map<Id, GRAX_Data_Record__c> dataRecords2Check = new Map<Id, GRAX_Data_Record__c>([SELECT Id, Status__c, of_Times_Sent__c, Error_Message__c FROM GRAX_Data_Record__c]);

        System.assertEquals(5, dataRecords2Check.get(dr.Id).of_Times_Sent__c);
        System.assertEquals(null, dataRecords2Check.get(dr.Id).Error_Message__c);
        System.assertEquals('Sent Successful', dataRecords2Check.get(dr.Id).Status__c);

        System.assertEquals(5, dataRecords2Check.get(dr2.Id).of_Times_Sent__c);
        System.assertEquals('Error', dataRecords2Check.get(dr2.Id).Status__c);
    }
}
