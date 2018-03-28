/* --------------------------------------------------------------------------
 * This file is subject to the terms and conditions defined in
 * file https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE,
 * which is part of this source code package.
 * --------------------------------------------------------------------------
 *          Copyright (c) 2017-2018 Harding Point
 *                  All rights reserved
 * --------------------------------------------------------------------------
 * Support:	Support@Grax.io
 * Website:	https://grax.io
 * Github:	https://github.com/HardingPoint/GRAXForSFDC
 * License:	https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE
 * --------------------------------------------------------------------------*/

public with sharing class GRAXSetupCtrl {
    // DEPLOY
	String LastAppName = '';
	GRAXSettings gxs = new GRAXSettings();
	public string graxconfig {get;set;}
    public boolean isauthorized {get;set;}
	public boolean isconfigured {get;set;}
	public boolean appselectdisabled {get;set;}
	public boolean disableeverything {get;set;}
	
	public boolean disableaudit {get;set;}
	public boolean appselected {
		get {
			if (graxsetting_apitoken!='' && graxsetting_gatewaytoken!='' && graxsetting_graphdburl!='' && graxsetting_licensetoken!='')
				return true;
			else
				return false;
		}
		set;
	}
	
	public string actiontext {get;set;}
	public string actionbuttontext {get;set;}
	
	public string graxapp {get;set;}
	public string graxappJSON {get;set;}
	
	// Should remove this and bind directly to settings object (Duh!)
	public string graxsetting_graxapp {get;set;}
	public string graxsetting_apitoken {get;set;}
	public string graxsetting_gatewaytoken  {get;set;}
	public string graxsetting_graphdburl {get;set;}
	public string graxsetting_flowurl {get;set;}
	public string graxsetting_apiurl {get;set;}
	public string graxsetting_s3accesskey {get;set;}
	public string graxsetting_s3secret {get;set;}
	public string graxsetting_s3bucket {get;set;}
	public string graxsetting_s3region {get;set;}
	public string graxsetting_licensetoken {get;set;}
	
	public List<SelectOption> graxapps {get;set;}

    public string graxstep {get;set;}

    public GRAXSetupCtrl() {
        // DEPLOY
        actiontext = 'Save';
        actionbuttontext = 'Save GRAX Settings';
        
        appselectdisabled = true;
        graxapps = new List<SelectOption>(); 
        graxapps.add(new SelectOption('','-- Choose Heroku Application --'));
        graxconfig = GetConfig();
        isauthorized = graxconfig!=null && graxconfig!='';
        graxapps = ParseJSON();
        isconfigured = false;
		
		if (GRAXSettings.IsConfigured()==false)
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please Select Application.'));
		
		LockSettings(GRAXSettings.IsConfigured());

        // CONFIGURATION
        isconfigured = GRAXSettings.IsConfigured();
        disablesave = true;
        if (isconfigured==false)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please complete <a href="/one/one.app#/n/GRAX_DEPLOY">GRAX Configuration</a>.'));
        else{
            sychedObjectsSaved = getSynchedObjects();
            RelatedToList = new Map<String,String>();
        }

        // FLOW
        if (GRAXSettings.IsConfigured()==false)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please complete <a href="/one/one.app#/n/GRAX_DEPLOY">GRAX Configuration</a>.'));
    }
    
    public pagereference AuthorizeHeroku(){
		pagereference p = new pagereference(GetUrl('/platforms/heroku/oauth/authorize'));
		return p;
    }
   	
   	public void LockSettings(Boolean LockFlag){
   		if (LockFlag){
   			actiontext = 'GRAX Settings';
   			actionbuttontext = 'Unlock';
   			disableeverything = true;
   			GRAXSettings settings = new GRAXSettings();
	    		graxsetting_apitoken = settings.graxConfig.ApiToken__c;
			graxsetting_gatewaytoken = settings.graxConfig.GatewayToken__c;
			graxsetting_licensetoken = settings.graxConfig.LicenseToken__c;
			graxsetting_graphdburl = settings.graxConfig.graphdburl__c;
			graxsetting_flowurl = settings.graxConfig.GRAX_Flow_URL__c;
			graxsetting_apiurl = settings.graxConfig.GRAX_API_Url__c;
			graxsetting_graxapp = settings.graxConfig.Heroku_App_Name__c;
			graxsetting_s3secret = settings.graxConfig.s3secretaccesskey__c;
			graxsetting_s3accesskey = settings.graxConfig.s3accesskeyid__c;
			
			graxsetting_s3bucket = settings.graxConfig.s3bucket__c;
			graxsetting_s3region = settings.graxConfig.s3region__c;

            graxapp = graxsetting_graxapp;
			
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'GRAX Settings Locked'));
   		}else{
   			actiontext = 'GRAX Settings';
   			actionbuttontext = 'Save';
   			disableeverything = false;
   			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'GRAX Settings Unlocked'));
   		}
   	}
   		 
    public pagereference UpdateCustomSettings(){
    		if (actionbuttontext=='Save'){
    			if (graxsetting_apitoken!='' && graxsetting_gatewaytoken!='' && graxsetting_licensetoken!='' && graxsetting_graphdburl!=''){
	    			GRAXSettings settings = new GRAXSettings();
				settings.graxConfig.ApiToken__c = graxsetting_apitoken;
				settings.graxConfig.GatewayToken__c = graxsetting_gatewaytoken;
				settings.graxConfig.LicenseToken__c =graxsetting_licensetoken;
				settings.graxConfig.graphdburl__c = graxsetting_graphdburl;
				settings.graxConfig.GRAX_Flow_URL__c = graxsetting_flowurl;
				settings.graxConfig.GRAX_API_Url__c = graxsetting_apiurl;
				settings.graxConfig.Heroku_App_Name__c = graxsetting_graxapp;
				
				settings.graxConfig.s3accesskeyid__c = graxsetting_s3accesskey;
				settings.graxConfig.s3secretaccesskey__c = graxsetting_s3secret;
				settings.graxConfig.s3bucket__c = graxsetting_s3bucket;
				settings.graxConfig.s3region__c = graxsetting_s3region;
				
				settings.UpdateSettings();
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Saved GRAX Settings.'));
	    		}
	    		LockSettings(true);
    		}
    		else
    			LockSettings(false);
    		
		return null;
    }

    public pagereference CancelCustomSettings() {
        pagereference pageRef = new pagereference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);

        return pageRef;
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

    public pagereference DeploySelectedApp(){
		pagereference p = new pagereference('https://dashboard.heroku.com/apps/' + graxapp + '/deploy/heroku-git');
		return p;
    }
    
    public String GetConfig(){
	    Http h = new Http();
	    HttpRequest req = new HttpRequest();
        req.setEndpoint(GetUrl('/platforms/heroku/getconfig'));
        req.setMethod('GET');

        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);

            if(res != null && String.valueOf(res.getStatusCode()).startsWith('2')) {
                return res.getBody();
            }

            return null;
	    } else {
            return graxconfig;
	    }
    }
    
    private String GetUrl(string path){
    		String Url = gxs.ApiURL + path + '?';
    		
    		if (!Test.isRunningTest()){
	    		Url += 'orgid=' + EncodingUtil.urlEncode(UserInfo.getOrganizationId(),'UTF-8');
	    		Url += '&userid=' + EncodingUtil.urlEncode(UserInfo.getUserId(),'UTF-8');
	    		
	    		if (ApexPages.currentPage().getHeaders().get('Host')!=null)
	    			Url += '&host=' + EncodingUtil.urlEncode(ApexPages.currentPage().getHeaders().get('Host'),'UTF-8');
	    		
	    		if (UserInfo.getOrganizationName()!=null)
	    			Url += '&companyname=' + EncodingUtil.urlEncode(UserInfo.getOrganizationName(),'UTF-8');
	    			
	    		if (UserInfo.getFirstName()!=null)
	    			Url += '&firstname=' + EncodingUtil.urlEncode(UserInfo.getFirstName(),'UTF-8');
	    			
	    		if (UserInfo.getLastName()!=null)	
	    			Url += '&lastname=' + EncodingUtil.urlEncode(UserInfo.getLastName(),'UTF-8');
	    			
	    		if (UserInfo.getUserEmail()!=null)	
	    			Url += '&email=' + EncodingUtil.urlEncode(UserInfo.getUserEmail(),'UTF-8');
    		}
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
    		if (appName!='' && appName != LastAppName && appName!=null){
    			try{
	    			Http h = new Http();
			    HttpRequest req = new HttpRequest();
			    req.setMethod('GET');
			    if(!Test.isRunningTest()){
			    		req.setEndpoint(GetUrl('/platforms/heroku/getappconfig') + '&appname=' + appName);
			    		HttpResponse res = h.send(req);
			    		graxappJSON = res.getBody();
			    	}
			    		
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
	    		if (isauthorized){
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

    // CONFIGURATION
    List<FieldProperties> FieldProperties;
    Map<String,GRAXQuery__c> sychedObjectsSaved;
    Map<String,String> RelatedToList;
    
    public string objToQuery {get;set;}
        
    public string defaultfields {get;set;}
    public string defaultfilter {get;set;}
    public string defaultprocessordering {get;set;}
    
    public boolean disablesynch {get;set;}
    public boolean disablesave {get;set;}
    public boolean historyprocessed {get;set;}
    
    public boolean auditenabled {get;set;}
    
    public string getPropURLToDisplay_Configuration() { 
        string salesforceURL = 'https://graphconnect.hardingpoint.com?sfdcobject=' + objToQuery + '&sfdcdomain=https://' + URL.getSalesforceBaseUrl().getHost() + '/'; 
        // string salesforceURL = 'https://graphconnect-test.herokuapp.com/?sfdcobject=' + objToQuery + '&sfdcdomain=https://' + URL.getSalesforceBaseUrl().getHost() + '/'; 
        
        return salesforceURL;
    }
    
    public pagereference DeployTrigger(){
        pagereference p=new pagereference(getPropURLToDisplay_Configuration());
        return p;
    }  
    
    public Map<String,GRAXQuery__c> getSynchedObjects()
    {
        return GRAXSettings.getSynchedObjects();
    }
    
    public List<FieldProperties> getfieldProperties()
    {
        String fieldName;
        FieldProperties= new List<FieldProperties>();
        
        SObjectType objType = Schema.getGlobalDescribe().get(objToQuery);
        if (objType != null)
        {
            disablesave = false;
            Map<String,Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
            for (String s : fields.keySet()) 
            {
                if (fields.get(s).getDescribe().isAccessible()){
                    fieldName = fields.get(s).getDescribe().getName();
                    FieldProperties.add(new FieldProperties(objtoquery, fieldName, sychedObjectsSaved));
                    // FieldProperties.add(new FieldProperties(objtoquery, s, sychedObjectsSaved));
                }
            }
        }
        SynchSaved(objToQuery);
        return FieldProperties;
    }
	    
	   
	public List<SelectOption> getItems() 
    {   
        String objectname;
        List<SelectOption> options = new List<SelectOption>();
        Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();
            options.add(new SelectOption('' ,'<---- SELECT SALESFORCE OBJECT ---->' ));
        for (String apiName : sObjects.keySet())
        {
            Map<String, Schema.RecordTypeInfo> types = sObjects.get(apiName).getDescribe().getRecordTypeInfosByName();
            if (types.size() > 0){
                // system.debug(apiName);
                // system.debug('[GRAX.io] Type: ' + sObjects.get(apiName).getDescribe().getRecordTypeInfosByName());
                // system.debug('[GRAX.io] Type: ' + sObjects.get(apiName).getDescribe().getName());
                objectname = sObjects.get(apiName).getDescribe().getName();
                // system.debug('[GRAX.io] ' + sObjects.get(apiName));
                // options.add(new SelectOption(apiName ,apiName ));
                
                objectname = sObjects.get(apiName).getDescribe().getName();
                options.add(new SelectOption(objectname ,objectname ));
            }
        }
        
        options.sort();
        
        return options;
    }
	    
    public class FieldProperties
    {
        private string sObjtoquery;
        public string fieldname{get;set;}
        public string fieldtype{get;set;}
        public string referenceto{get;set;}
        public string message{get;set;}
        
        public boolean fieldselected{get;set;}
        public boolean disabled{get;set;} 		// Disable if Object not Synched
        
        public FieldProperties() {}  
        
        public FieldProperties(string objname, string fieldname, Map<String,GRAXQuery__c> sychedObjectsSaved) {
            this.sObjtoquery = objname;
            this.fieldname = fieldname;
            this.fieldselected = false;
            getAttributes(objname, fieldname, sychedObjectsSaved);
        }
    
        public void getAttributes(string objtoquery, string afieldname, Map<String,GRAXQuery__c> sychedObjectsSaved)
        {
            SObjectType objType = Schema.getGlobalDescribe().get(objtoquery);
            Map<String,Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
            if (fields.get(afieldname).getDescribe().isAccessible())
            {  
                fieldname = afieldname;
                fieldtype = string.valueof(fields.get(afieldname).getDescribe().getType());
                if (fieldname=='name' || fieldname=='id'){
                    fieldselected=true;
                } else if (fieldtype=='REFERENCE') {
                    referenceto = string.valueof(fields.get(afieldname).getDescribe().getReferenceTo()).replace('(','').replace(')','');
                    if (sychedObjectsSaved.get(referenceto)!=null || sychedObjectsSaved.get(referenceto.toLowerCase())!=null || referenceto.toLowerCase()==objToQuery.toLowerCase()){
                        fieldselected=true;
                        message = 'Synchronized';
                    } else {
                        fieldselected=false;
                        disabled = true;
                        message = 'Not Synchronized';
                    }
                }
            }
        }
    } 
    
    Public Pagereference QueryObject() {
        return null;
    }
    
    private void SynchSaved(String ObjectName){
        if (ObjectName!='' && ObjectName!=null)
        {
            integer counter = 0;
            disablesave = false;
            GRAXSettings gxs = new GRAXSettings(ObjectName);
            if (gxs.isObjectConfigured){
                disablesynch = false;
                defaultfilter = gxs.GRAXQuery.Filter__c;
                defaultprocessordering = gxs.GRAXQuery.Order_By__c;
                defaultfields = gxs.GRAXQuery.Selected_Fields__c;
                graxconfig = gxs.GRAXQuery.graxconfig__c;
                auditenabled = gxs.GRAXQuery.Enable_Audit_Log__c;
                string currentfields = ','+ gxs.GRAXQuery.Selected_Fields__c + ',';
                
                
                for(FieldProperties obj : FieldProperties){
                    if (currentfields.indexOf(',' + obj.fieldname + ',') >0 ){
                        FieldProperties[counter].fieldselected=true;
                    }
                    counter++;
                }
            } else {
                disablesynch = true;
                defaultprocessordering = 'LastModifiedDate DESC';
                defaultfilter = '';
                auditenabled = false;
                // defaultfilter = 'CALENDAR_YEAR(LastModifiedDate) > 2016';
                SynchSelectedFields();
            }
        } else {
            disablesave = true;
            disablesynch = true;
            defaultprocessordering = '';
            graxconfig = '';
            defaultfilter = '';
            defaultfields = '';
        }
    }
    
    private void SynchSelectedFields(){
        string fieldlist = ''; 	
        String TypeMap = '';	 
        List<FieldProperties> SelectedProperties = new List<FieldProperties>();
        for(FieldProperties obj : FieldProperties){
            if (obj!=null){
                if (obj.fieldselected){
                    SelectedProperties.add(obj);
                    if (TypeMap!='')
                        TypeMap+= ',';
                        
                    if (obj.referenceto!=null){
                        RelatedToList.put(obj.fieldname, obj.referenceto);
                    }
                    
                    TypeMap += '\"' + obj.fieldname + '\":\"' + obj.fieldtype + '\"';
                        
                    if (fieldlist!='')
                        fieldlist+=',';
                        
                    fieldlist+=obj.fieldname;
                    
                }
                
            }
        }
        // graxconfig = JSON.serialize(SelectedProperties);
        graxconfig = '{"sobject":\"' + objToQuery + '\",' + 
                            '"fieldsselected":"' + fieldlist + '",' +
                            '"orderby":"' + defaultprocessordering + '",' + 
                            '"filterby":"' + defaultfilter+ '",' + 
                            '"typemap":{' + TypeMap + '},' + 
                            '"lookupmap":' + 
                                JSON.serialize(RelatedToList) + 
                        '}';
        
        defaultfields = fieldlist;
    }
    
    public Pagereference UpdateFieldList()
    {
        SynchSelectedFields();
        return null;
    }
    
    Public Pagereference SaveSelection()
    {    
        GRAXApi.cloudconfig(objToQuery);
        GRAXQuery__c newQuery = new GRAXQuery__c();
        newQuery.ObjectName__c = objToQuery;
        SynchSelectedFields();
        newQuery.Selected_Fields__c = defaultfields;
        newQuery.Order_By__c=defaultprocessordering;
        newQuery.Filter__c=defaultfilter;
        newQuery.graxconfig__c = graxconfig;
        newQuery.Enable_Audit_Log__c = auditenabled;
        newQuery.GRAX_Configured__c=Datetime.now();
        upsert newQuery ObjectName__c;
        sychedObjectsSaved = getSynchedObjects();
        disablesynch = false;
        return null;   
    }
    
    Public Pagereference Synchronize(){ 
        SaveSelection();
        GRAXBatch.ProcessHistory(objToQuery);
        historyprocessed = true;
        return null;
    }

    // FLOW
    
    public string getPropURLToDisplay_Flow() { 
        String flowUrl = 'https://grax.io';
        GRAXSettings__c graxsettings = GRAXSettings__c.getOrgDefaults();
        if (graxsettings.GRAX_Flow_URL__c!=null)
            flowUrl = graxsettings.GRAX_Flow_URL__c; 
        return flowUrl;
    }
    
    public pagereference connect(){
        pagereference p=new pagereference(getPropURLToDisplay_Flow());
        return p;
    }
}
