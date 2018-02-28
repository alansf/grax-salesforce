public with sharing class GRAXDeploy {

	String LastAppName = '';
	GRAXSettings gxs = new GRAXSettings();
	public string graxconfig {get;set;}
	public boolean isconfigured {get;set;}
	public boolean appselectdisabled {get;set;}
	public boolean appselected {
		get {
			if (graxsetting_apitoken!='' && graxsetting_gatewaytoken!='' && graxsetting_graphdburl!='' && graxsetting_licensetoken!='')
				return true;
			else
				return false;
		}
		set;
	}
	public string graxapp {get;set;}
	public string graxappJSON {get;set;}
	public string graxsetting_apitoken {get;set;}
	public string graxsetting_gatewaytoken  {get;set;}
	public string graxsetting_graphdburl {get;set;}
	public string graxsetting_flowurl {get;set;}
	public string graxsetting_apiurl {get;set;}
	public string graxsetting_licensetoken {get;set;}
	public List<SelectOption> graxapps {get;set;} 
	
    public GRAXDeploy() {
    		appselectdisabled = true;
    		graxapps = new List<SelectOption>(); 
    		graxapps.add(new SelectOption('','--SELECT APP--'));
    		graxconfig = GetConfig();	
    		graxapps = ParseJSON();
    		isconfigured = false;
    }
    
    public pagereference AuthorizeHeroku(){
		pagereference p = new pagereference(GetUrl('/platforms/heroku/oauth/authorize'));
		return p;
    }
   		 
    public pagereference UpdateCustomSettings(){
    		if (graxsetting_apitoken!='' && graxsetting_gatewaytoken!='' && graxsetting_licensetoken!='' && graxsetting_graphdburl!=''){
    			GRAXSettings settings = new GRAXSettings();
			settings.graxConfig.ApiToken__c = graxsetting_apitoken;
			settings.graxConfig.GatewayToken__c = graxsetting_gatewaytoken;
			settings.graxConfig.LicenseToken__c =graxsetting_licensetoken;
			settings.graxConfig.graphdburl__c = graxsetting_graphdburl;
			settings.graxConfig.GRAX_Flow_URL__c = graxsetting_flowurl;
			settings.graxConfig.GRAX_API_Url__c = graxsetting_apiurl;
			
			settings.UpdateSettings();
    		}
		return null;
    }
    
    public pagereference LoginToHeroku(){
		pagereference p = new pagereference('https://id.heroku.com/login');
		return p;
    }
    
    public pagereference SignUpHeroku(){
		pagereference p = new pagereference('https://signup.heroku.com/?c=70130000001x9jFAAQ');
		return p;
    }
    
    public pagereference DeployGraxApp(){
		pagereference p = new pagereference('https://heroku.com/deploy?template=https://github.com/HardingPoint/GRAX/blob/master');
		return p;
    }
    
    public String GetConfig(){
	    Http h = new Http();
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(GetUrl('/platforms/heroku/getconfig'));
	    req.setMethod('GET');
	    HttpResponse res = h.send(req);
	    return res.getBody();
    }
    
    private String GetUrl(string path){
    		String Url = gxs.ApiURL + path + '?';
    		Url += 'orgid=' + UserInfo.getOrganizationId();
    		Url += '&userid=' + UserInfo.getUserId();
    		Url += '&host=' + ApexPages.currentPage().getHeaders().get('Host');
    		return Url;
    }

    public string getGRAXAppConfig(){
    		graxappJSON = queryAppConfig(graxapp);
		return graxappJSON;
    	}
    	
    	public void setGRAXAppConfig(String newValue){
		graxappJSON = queryAppConfig(graxapp);
    	}
    
    public String queryAppConfig(String appName){
    		graxappJSON = '';
    		if (appName!='' && appName != LastAppName){
    			Http h = new Http();
		    HttpRequest req = new HttpRequest();
		    req.setEndpoint(GetUrl('/platforms/heroku/getappconfig') + '&appname=' + appName);
		    req.setMethod('GET');
		    HttpResponse res = h.send(req);
		    graxappJSON = res.getBody();
		    LastAppName = appName;
		    
		    graxsetting_apitoken = GetAppConfig('ENGAGEMENTGRAPH_APITOKEN');
		    graxsetting_gatewaytoken = GetAppConfig('ENGAGEMENTGRAPH_GATEWAYTOKEN');
		    graxsetting_graphdburl = GetAppConfig('GRAPHCONNECT_URL');
		    graxsetting_licensetoken = GetAppConfig('ENGAGEMENTGRAPH_LICENSETOKEN');
		    graxsetting_flowurl = 'https://' + appName + '.herokuapp.com';
		    graxsetting_apiurl = 'https://test.hardingpoint.com/v9.3/api';
    		}
    		return graxappJSON;
    }
    
    public String GetAppConfig(String fieldName){
    		String ReturnValue = '';
    		if (graxappJSON!='' && graxappJSON!=null){
    			JSONParser parser = JSON.createParser(graxappJSON);
    			while (parser.nextToken() != null) {
    				if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == fieldName){
        				parser.nextToken();
        				ReturnValue = parser.getText();
        				system.debug('[GRAX.io] FOUND SETTING : ' + fieldName + '=' + ReturnValue);
        			}
        		}
    		}
    		return ReturnValue;
    }
    
    public List<SelectOption> ParseJSON(){
    		String FieldName = '';
    		String FieldValue = '';
    		String GraxAppName = '';
        if (graxconfig!=null && graxconfig!=''){
        		JSONParser parser = JSON.createParser(graxconfig);
        		while (parser.nextToken() != null) {
        			if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
        			{
        				FieldName = parser.getText();
        				parser.nextToken();
        				FieldValue = parser.getText();
        				
        				if (FieldName=='authorized')
        					isconfigured = true;
        				
        				if (FieldName=='name')
        					GraxAppName = FieldValue;
        				
        				if (FieldName=='id'){
        					appselectdisabled = false;
        					system.debug('[GRAX.io] ' + GraxAppName + '=' + FieldValue);
        					graxapps.add(new SelectOption(GraxAppName,GraxAppName)); 
        				}
        			}	
        		}
        }
        
        graxapps.sort();
        return graxapps;
   	}
}
