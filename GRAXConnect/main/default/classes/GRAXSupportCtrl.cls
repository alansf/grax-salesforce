public with sharing class GRAXSupportCtrl {
    public string exceptionlist {get;set;}
    public GRAXLogging GRAXLogInfo {get;set;}
    
    public String LoggingJSON {get;set;}
    
    public GRAXSupportCtrl() {
		GRAXLogInfo = GRAXLogging.GetExceptions();
		LoggingJSON = GRAXLogInfo.LogJSON;
    }
    
}
