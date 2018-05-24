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
        List<Account> accList = new List<Account>{
            new Account(Name='TestAccount1'),
            new Account(Name='TestAccount2'),
            new Account(Name='TestAccount3')
        };

        insert accList;

        for(Account acc : accList) {
            System.assertNotEquals(null, acc.Id);

            GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
            dr.Salesforce_Object__c = 'Account';
            dr.Status__c = 'Sent Successful';
            dr.of_Times_Sent__c = 0;
            dr.Error_Message__c = null;
            insert dr;

            System.assertNotEquals(null, dr.Id);

            Attachment req_att = new Attachment();
            req_att.Name = 'request.txt';
            req_att.Body = Blob.valueOf('{}');
            req_att.ParentId = dr.Id;
            insert req_att;
            
            System.assertNotEquals(null, req_att.Id);
            
            GRAX_Data_Record_Id__c dataRecId = new GRAX_Data_Record_Id__c();
            dataRecId.SFDC_Id__c = acc.Id;
            dataRecId.GRAX_Data_Record__c = dr.Id;
            dataRecId.Status__c = 'To be Deleted';
            
            insert dataRecId;

            System.assertNotEquals(null, dataRecId.Id);
        }

        Test.startTest();

        GRAXBatchToDeleteBackedUpData b = new GRAXBatchToDeleteBackedUpData();
        Id jobId = Database.executebatch(b);

        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM GRAX_Data_Record_Id__c WHERE Status__c = 'Successfully Deleted' LIMIT 3].size());
        System.assertEquals(0, [SELECT Id FROM Account LIMIT 3].size());
    }
}
