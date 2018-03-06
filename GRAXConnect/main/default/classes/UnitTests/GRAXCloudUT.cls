
@isTest
private class GRAXCloudUT{

    @isTest
    static void ConstructorTest() {
    		GRAXSettings gxs = GRAXUnitTest.getSettings();
        GRAXCloud gx = new GRAXCloud();
    }
    
    @isTest
    static void calloutnowTest() {
    	   GRAXSettings gxs = GRAXUnitTest.getSettings();
       GRAXCloud.calloutnow('http://test.grax.io','{}');
    }
    
    @isTest
    static void calloutTest() {
    	   GRAXSettings gxs = GRAXUnitTest.getSettings();
       GRAXCloud.callout('http://test.grax.io','{}');
    }
    
    
}