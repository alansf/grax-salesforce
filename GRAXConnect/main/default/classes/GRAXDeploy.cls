public with sharing class GRAXDeploy {

	GRAXSettings gxs = new GRAXSettings();
	
	public string graxconfig {get;set;}
	public boolean isconfigured {get;set;}
	public string graxapp {get;set;}
	
	public List<SelectOption> graxapps {get;set;} 
	
    public GRAXDeploy() {
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
    
    public string GRAXAppConfig {
    		get { return queryAppConfig(graxapp);}
    		set;
    	}
    
    public String queryAppConfig(String appName){
    		String returnValue = '';
    		if (appName!=''){
    			Http h = new Http();
		    HttpRequest req = new HttpRequest();
		    req.setEndpoint(GetUrl('/platforms/heroku/getappconfig') + '&appname=' + appName);
		    req.setMethod('GET');
		    HttpResponse res = h.send(req);
		    returnValue=res.getBody();
    		}
    		return returnValue;
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
        					system.debug('[GRAX.io] ' + GraxAppName + '=' + FieldValue);
        					graxapps.add(new SelectOption(FieldValue,GraxAppName)); 
        				}
        			}	
        		}
        }
        
        // graxapps.sort();
        return graxapps;
   	}
}
