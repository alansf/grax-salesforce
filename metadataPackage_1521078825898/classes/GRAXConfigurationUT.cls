
@isTest
public with sharing class GRAXConfigurationUT {

	@isTest
    static void ConstructorTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
		GRAXConfiguration config = GRAXConfigurationUT.Initialize();
    }
    
    @isTest
    static void TestNotConfiguredPage() {
		PageReference pageRef = Page.GRAXConfiguration;
    		Test.setCurrentPage(pageRef);  
    }
    
    @isTest
    static void TestPage() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
		PageReference pageRef = Page.GRAXConfiguration;
    		Test.setCurrentPage(pageRef);  	
    }
    
    public static GRAXConfiguration Initialize(){
    		GRAXConfiguration config = new GRAXConfiguration();
    		config.objToQuery = 'Account';
    		
    		config.getPropURLToDisplay();
    		config.DeployTrigger();
    		config.getSynchedObjects();
    		
    		config.getfieldProperties();
    		config.getItems();
    		
    		config.QueryObject();
    		config.UpdateFieldList();
    		
    		config.SaveSelection();
    		
    		return config;
    }
}
