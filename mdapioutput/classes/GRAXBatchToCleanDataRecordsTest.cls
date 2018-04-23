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
        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
		dr.Salesforce_Object__c = 'Test';
		dr.Status__c = 'Sent Successful';
        dr.Last_Sent_Date__c = Date.today().addDays(-3);

        GRAX_Data_Record__c dr2 = new GRAX_Data_Record__c();
		dr2.Salesforce_Object__c = 'Test';
		dr2.Status__c = 'Sent Successful';
        dr2.Last_Sent_Date__c = Date.today().addDays(-1);

        GRAX_Data_Record__c dr3 = new GRAX_Data_Record__c();
		dr3.Salesforce_Object__c = 'Test';
		dr3.Status__c = 'Sent Successful';
        dr3.Last_Sent_Date__c = Date.today();

		insert new List<GRAX_Data_Record__c> { dr, dr2, dr3 };

        Test.startTest();
        database.executebatch(new GRAXBatchToCleanDataRecords());
        Test.stopTest();
        
        Map<Id, GRAX_Data_Record__c> dataRecords2Check = new Map<Id, GRAX_Data_Record__c>([SELECT Id FROM GRAX_Data_Record__c WHERE Id IN : new List<GRAX_Data_Record__c>{dr, dr2, dr3}]);

        System.assertEquals(null, dataRecords2Check.get(dr.Id));
        System.assertNotEquals(null, dataRecords2Check.get(dr2.Id));
        System.assertNotEquals(null, dataRecords2Check.get(dr3.Id));
    }
}
