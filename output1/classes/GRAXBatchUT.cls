
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
      	GRAXBatch.ProcessHistory('Account');
    }
    
}
