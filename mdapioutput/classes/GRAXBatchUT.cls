
@isTest(SeeAllData=true)
public with sharing class GRAXBatchUT {
    
    @isTest
    static void ConstructorTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	// GRAXBatch batch = new GRAXBatch('Account');
      	// batch = new GRAXBatch('Contact');
      	// batch = new GRAXBatch('Lead');
      	// batch = new GRAXBatch('Opportunity');
    }
    
    @isTest
    static void ProcessHistoryTest() {
		GRAXSettings gxs = GRAXUnitTest.getSettings();

		GRAXUnitTest.SingleRequestMock fakeResponse = new GRAXUnitTest.SingleRequestMock(200, '{}', 'http://test.grax.io', null);
        
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        GRAXBatch.ProcessHistory('Account');

        Test.stopTest();
    }
    
}
