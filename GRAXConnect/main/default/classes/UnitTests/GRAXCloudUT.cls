
@isTest
private class GRAXCloudUT{

    @isTest
    static void ConstructorTest() {
        GRAXSettings gxs = GRAXUnitTest.getSettings();
        GRAXCloud gx = new GRAXCloud();
    }
    
    /*****************************************************************************************
    Name              : calloutnowTest
    Description       : 
    Revision History  :
    Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
    ----------------------------------------------------------------------------------------
    1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
    ******************************************************************************************/
    @isTest
    static void calloutnowTest() {
        GRAXSettings gxs = GRAXUnitTest.getSettings();
        SingleRequestMock fakeResponse = new SingleRequestMock(200, '{"message": "Test successful"}', 'http://test.grax.io', null);
		
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        GRAXCloud.calloutnow('http://test.grax.io','{}');

        Test.stopTest();
    }
    
    /*****************************************************************************************
    Name              : calloutTest
    Description       : 
    Revision History  :
    Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
    ----------------------------------------------------------------------------------------
    1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
    ******************************************************************************************/
    @isTest(seeAllData = false)
    static void calloutTest() {
        GRAXSettings gxs = GRAXUnitTest.getSettings();

		SingleRequestMock fakeResponse = new SingleRequestMock(200, '{"message": "Test successful"}', 'http://test.grax.io/applications/neo4j/configure', null);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        GRAXCloud.callout('http://test.grax.io', '{}', 'Test', '');

        Test.stopTest();

        GRAX_Data_Record__c dr = [SELECT Salesforce_Object__c, Status__c FROM GRAX_Data_Record__c LIMIT 1];

        System.assertEquals('Sent Successful', dr.Status__c);
    }

    /*****************************************************************************************
    Name              : calloutTest2
    Description       : 
    Revision History  :
    Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
    ----------------------------------------------------------------------------------------
    1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
    ******************************************************************************************/
    @isTest(seeAllData = false)
    static void calloutTest2() {
        GRAXSettings gxs = GRAXUnitTest.getSettings();

        SingleRequestMock fakeResponse = new SingleRequestMock(408, '{"message": "Request Timeout"}', 'http://test.grax.io/applications/neo4j/configure', null);
        
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        GRAXCloud.callout('http://test.grax.io', '{}', 'Test', '');

        Test.stopTest();

        GRAX_Data_Record__c dr = [SELECT Salesforce_Object__c, Status__c FROM GRAX_Data_Record__c LIMIT 1];

        System.assertEquals('Error', dr.Status__c);
    }

    /*****************************************************************************************
    Name              : SingleRequestMock
    Description       : 
    Revision History  :
    Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
    ----------------------------------------------------------------------------------------
    1. Leandro Brunner       04/17/2018				David Mackey        https://app.asana.com/0/326600806074978/633149554508924/f
    ******************************************************************************************/
    public class SingleRequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;
        
        public SingleRequestMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }
        
        public SingleRequestMock(Integer code, String status, Blob body, Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);

            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            } else {
                resp.setBody(bodyAsString);
            }
            
            if (responseHeaders != null) {
                for (String key : responseHeaders.keySet()) {
                    resp.setHeader(key, responseHeaders.get(key));
                }
            }

            return resp;
        }
    }
    
}