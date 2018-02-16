public virtual with sharing class GRAXCloud extends GRAXSettings{
	//Class that manages full communication with GRAX Cloud.

	// Constructor
    //public GRAXCloud() {	
    //} 
    
    // Main method for calling out to GRAX cloud
    public static void calloutnow(String url, String content) {
        GRAXCloud gx = new GRAXCloud();
        if (gx.ProperlyConfigured){
        		Http h = new Http();
        		HttpRequest req = new HttpRequest();
        		// ------------------------------
	        if (url==''){
	            req.setEndpoint(gx.ApiURL);
	        }else{
	            req.setEndpoint(url);
	        }
	        // ------------------------------
        		req.setMethod('POST');
        		req.setHeader('Content-Type', 'application/json');
        		req.setHeader('licensetoken',gx.LicenseToken);
        		req.setHeader('authorizationToken', gx.ApiToken);
        		req.setHeader('x-api-key', gx.GatewayToken);
        		req.setHeader('sfdcorgid', UserInfo.getOrganizationId());
	        req.setBody(content);
	        h.send(req);
        }
    }
    
    @future(callout=true)
    public static void callout(String url, String content) {
        GRAXCloud.calloutnow(url,content);
    }
    
}
