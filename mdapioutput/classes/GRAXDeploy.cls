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
	public string graxsetting_graxapp {get;set;}
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
    		graxapps.add(new SelectOption('','-- Select Heroku Application --'));
    		graxconfig = GetConfig();	
    		graxapps = ParseJSON();
    		isconfigured = false;
    		
    		GRAXSettings settings = new GRAXSettings();
    		graxsetting_apitoken = settings.graxConfig.ApiToken__c;
		graxsetting_gatewaytoken = settings.graxConfig.GatewayToken__c;
		graxsetting_licensetoken = settings.graxConfig.LicenseToken__c;
		graxsetting_graphdburl = settings.graxConfig.graphdburl__c;
		graxsetting_flowurl = settings.graxConfig.GRAX_Flow_URL__c;
		graxsetting_apiurl = settings.graxConfig.GRAX_API_Url__c;
		graxsetting_graxapp = settings.graxConfig.Heroku_App_Name__c;
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
			settings.graxConfig.Heroku_App_Name__c = graxsetting_graxapp;
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
    		Url += 'orgid=' + EncodingUtil.urlEncode(UserInfo.getOrganizationId(),'UTF-8');
    		Url += '&userid=' + EncodingUtil.urlEncode(UserInfo.getUserId(),'UTF-8');
    		Url += '&host=' + EncodingUtil.urlEncode(ApexPages.currentPage().getHeaders().get('Host'),'UTF-8');
    		Url += '&companyname=' + EncodingUtil.urlEncode(UserInfo.getOrganizationName(),'UTF-8');
    		Url += '&firstname=' + EncodingUtil.urlEncode(UserInfo.getFirstName(),'UTF-8');
    		Url += '&lastname=' + EncodingUtil.urlEncode(UserInfo.getLastName(),'UTF-8');
    		Url += '&email=' + EncodingUtil.urlEncode(UserInfo.getUserEmail(),'UTF-8');
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
    			try{
	    			Http h = new Http();
			    HttpRequest req = new HttpRequest();
			    req.setEndpoint(GetUrl('/platforms/heroku/getappconfig') + '&appname=' + appName);
			    req.setMethod('GET');
			    HttpResponse res = h.send(req);
			    graxappJSON = res.getBody();
			    LastAppName = appName;
			    
			    graxsetting_graxapp = appName;
			    graxsetting_apitoken = GetAppConfig('ENGAGEMENTGRAPH_APITOKEN');
			    graxsetting_gatewaytoken = GetAppConfig('ENGAGEMENTGRAPH_GATEWAYTOKEN');
			    graxsetting_graphdburl = GetAppConfig('GRAPHCONNECT_URL');
			    graxsetting_licensetoken = GetAppConfig('ENGAGEMENTGRAPH_LICENSETOKEN');
			    graxsetting_flowurl = 'https://' + appName + '.herokuapp.com';
			    graxsetting_apiurl = ''; // Let it default to code base
			    
			} catch (Exception e) {
			     //Generic exception handling code here
			} finally {
			     //optional finally block
			     //code to run whether there is an exception or not
			}
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
    		try{
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
		} catch (Exception e) {
		     //Generic exception handling code here
		} finally {
		     //optional finally block
		     //code to run whether there is an exception or not
		}
    		
        
        graxapps.sort();
        return graxapps;
   	}
}