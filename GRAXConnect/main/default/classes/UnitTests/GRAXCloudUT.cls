
@isTest
private class GRAXCloudUT {

    @isTest
    static void ConstructorTest() {
        GRAXCloud gx = new GRAXCloud();
    }
    
    @isTest
    static void CalloutTest() {
       GRAXCloud.calloutnow('http://test.grax.io','{}');
    }
}