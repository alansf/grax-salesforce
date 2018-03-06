
@isTest(SeeAllData=true)
public with sharing class GRAXApiUT {

    @isTest
    static void graxconfigTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	GRAXApi.graxconfig('Account');
    }
    
    @isTest
    static void graxconfigBadTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	GRAXApi.graxconfig('JunkDataObjectGRAX');
    }
    
    @isTest
    static void cloudconfigTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	GRAXApi.cloudconfig('Account');
    }
    
    @isTest
    static void mockTest() {
      	GRAXApi.mock('Account');
      	GRAXApi.mock('Case');
      	GRAXApi.mock('Opportunity');
      	GRAXApi.mock('Contact');
    }
    
    @isTest
    static void jsonContentInsertBadTest() {
    		// Bad Call
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	String results = GRAXApi.jsonContent(null,null);
    }
    
    @isTest
    static void jsonContentInsertTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	List<SObject> acctList = GRAXUnitTest.getTestAccount();
      	String results = GRAXApi.jsonContent(acctList,null);
    }
    
    @isTest
    static void jsonContentUpdateTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	List<SObject> acctList = GRAXUnitTest.getTestAccount();
      	String results = GRAXApi.jsonContent(acctList,acctList);
    }
    
    @isTest
    static void jsonContentDeleteTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	List<SObject> acctList = GRAXUnitTest.getTestAccount();
      	String results = GRAXApi.jsonContent(null,acctList);
    }
    
    @isTest
    static void jsonContentUpdateWithConfigTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
      	List<SObject> acctList = GRAXUnitTest.getTestAccount();
      	String results = GRAXApi.jsonContent(acctList,acctList,'{}');
    }
}
