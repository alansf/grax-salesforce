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
	
	public GRAXSettings gxs {get;set;}
	
	public string graxconfig {get;set;}
    public boolean isauthorized {get;set;}
	public boolean isconfigured {get;set;}
	public boolean appselectdisabled {get;set;}
	public boolean disableeverything {get;set;}
	
	public boolean appselected {
		get {
			if (gxs.ProperlyConfigured == true)
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
	public boolean disablefielauditddeploy {get;set;}
	public List<SelectOption> graxapps {get;set;}

    public GRAXSetupCtrl() {
        // DEPLOY
 
        gxs = new GRAXSettings();
        
        actiontext = 'Save';
        actionbuttontext = 'Save GRAX Settings';
        
        disablefielauditddeploy = true;
        
        appselectdisabled = true;
        graxapps = new List<SelectOption>(); 
        graxapps.add(new SelectOption('','-- Choose Heroku Application --'));
        graxconfig = GetConfig();
        graxapps = ParseJSON();
        isauthorized = String.isNotBlank(graxconfig) && graxapps.size() > 1;

		if (gxs.ProperlyConfigured == false)
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please Select Application.'));
		
		LockSettings(gxs.ProperlyConfigured);
		
		LoadAuditTrail();

        disablesave = true;
        if (gxs.ProperlyConfigured==false)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please complete <a href="/one/one.app#/n/GRAX_SETUP">GRAX Configuration</a>.'));
        else{
            sychedObjectsSaved = getSynchedObjects();
            RelatedToList = new Map<String,String>();
        }
        objToQuery = '';

        // FLOW
        if (gxs.ProperlyConfigured==false)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please complete <a href="/one/one.app#/n/GRAX_SETUP">GRAX Configuration</a>.'));
    }

    /*****************************************************************************************
	Name              : verifySchedules
	Description       : 
	Revision History  :
	Created/Modified by   Created/Modified Date     Requested by		Related Task/Issue     
	----------------------------------------------------------------------------------------
	1. Leandro Brunner       04/18/2018				David Mackey		https://app.asana.com/0/326600806074978/633149554508924/f
	******************************************************************************************/
    public static void verifySchedules() {
        String schedulerToCleanDataRecords = 'GRAXSchedulerToCleanDataRecords';
        String schedulerToResendDataRecords = 'GRAXSchedulerToResendDataRecords';

        Set<String> crons = new Set<String>();

        // Get CronTiggers if exist, and add Name to the Set.
        for(CronTrigger ct : [
            SELECT CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name IN :new List<String>{ schedulerToCleanDataRecords, schedulerToResendDataRecords + '0', schedulerToResendDataRecords + '1' }
        ]) {
            crons.add(ct.CronJobDetail.Name);
        }

        // Verify if the scheduler is not in the queue and adds it.
        if(!crons.contains(schedulerToCleanDataRecords)) {
            // Schedule job to run every day at 12 AM
            String jobId = System.schedule(schedulerToCleanDataRecords, '0 0 1 ? * MON-SUN', new GRAXSchedulerToCleanDataRecords());
        }

        // Code to schedule this process every 30 mins
        Integer minutesFactor = 30;
        String cronExpression = '';

        for(Integer i = 0; i < 2; i++){
            String cronName = schedulerToResendDataRecords + String.valueOf(i);

            // Verify if the scheduler is not in the queue and adds it.
            if(!crons.contains(cronName)) {
                cronExpression = '0 '+ String.valueOf(i * minutesFactor) + ' * * * ?'; 
                String jobId = System.schedule(cronName, cronExpression, new GRAXSchedulerToResendDataRecords());
            }
        }
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
            graxapp = gxs.graxConfig.Heroku_App_Name__c;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'GRAX Settings Locked'));
   		}else{
   			actiontext = 'GRAX Settings';
   			actionbuttontext = 'Save';
   			disableeverything = false;
   			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'GRAX Settings Unlocked'));
   		}
   	}
   	
   	public void LoadAuditTrail(){
   		if (gxs.graxConfig.Postgres_URL__c!=''){
				GRAXAuditTrail audittrail = new GRAXAuditTrail();
        			String auditsettings = audittrail.GetAuditSettings(gxs.graxConfig.Postgres_URL__c);
        			if (audittrail.numberoftables == 0)
        				disablefielauditddeploy = false;
        			else
        				disablefielauditddeploy = true;
		}
   	}
    
    public pagereference UpdateAuditTrail(){
		gxs.UpdateSettings();
		LoadAuditTrail();
		return null;
    } 		 
   		 
    public pagereference UpdateCustomSettings(){
    		if (actionbuttontext=='Save'){
                if(String.isBlank(gxs.graxConfig.GRAX_API_Url__c)) {
                    gxs.graxConfig.GRAX_API_Url__c = 'https://' + gxs.graxConfig.Heroku_App_Name__c + '.herokuapp.com/graxproxy/api';
                }
    			if (gxs.graxConfig.ApiToken__c!='' && gxs.graxConfig.GatewayToken__c!='' && gxs.graxConfig.LicenseToken__c!='' && gxs.graxConfig.graphdburl__c!=''){
                    gxs.UpdateSettings();
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Saved GRAX Settings.'));
	    		}
	    		LockSettings(true);
    		}
    		else
    			LockSettings(false);
    		
		return null;
    }
    
    public pagereference CreateParitions(){
		if (gxs.graxConfig.Postgres_URL__c!=''){
			GRAXAuditTrail audittrail = new GRAXAuditTrail();
        		audittrail.CreateAuditSettings(gxs.graxConfig.Postgres_URL__c,1000);
        	}
		return null;
    }
    
    public pagereference DropParitions(){
		if (gxs.graxConfig.Postgres_URL__c!=''){
			GRAXAuditTrail audittrail = new GRAXAuditTrail();
        		audittrail.DropAuditParitions(gxs.graxConfig.Postgres_URL__c,1000);
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
		pagereference p = new pagereference(gxs.GRAXDeployURL);
		return p;
    }

    public pagereference DeploySelectedApp(){
		pagereference p = new pagereference(gxs.GRAXDeployURL);	
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
			    gxs.graxConfig.Heroku_App_Name__c = appName;
			    gxs.graxConfig.ApiToken__c = GetAppConfig('ENGAGEMENTGRAPH_APITOKEN');
			    gxs.graxConfig.GatewayToken__c = GetAppConfig('ENGAGEMENTGRAPH_GATEWAYTOKEN');
			    gxs.graxConfig.graphdburl__c = GetAppConfig('GRAPHCONNECT_URL');
			    gxs.graxConfig.LicenseToken__c = GetAppConfig('ENGAGEMENTGRAPH_LICENSETOKEN');
			    gxs.graxConfig.Postgres_URL__c = GetAppConfig('DATABASE_URL');
			    gxs.graxConfig.GRAX_Flow_URL__c = 'https://' + appName + '.herokuapp.com';
                gxs.graxConfig.GRAX_API_Url__c = 'https://' + appName + '.herokuapp.com/graxproxy/api';
			    
			    // Move API to Proxy
			    // gxs.graxConfig.GRAX_API_Url__c = 'https://' + appName + '.herokuapp.com/graxproxy/api';
			    // gxs.ApiURL = 'https://' + appName + '.herokuapp.com/graxproxy/api';
			    
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
	    		if (String.isNotBlank(graxconfig)){
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
        gxs.SynchedObjects = GRAXSettings.getSynchedObjects();
    	
        return gxs.SynchedObjects;
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
            options.add(new SelectOption('' ,'-- SELECT SALESFORCE OBJECT --', true));
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

        public boolean fieldauditenabled{get;set;}
        
        public FieldProperties() {}  
        
        public FieldProperties(string objname, string fieldname, Map<String,GRAXQuery__c> sychedObjectsSaved) {
            this.sObjtoquery = objname;
            this.fieldname = fieldname;
            
           	Boolean defaultSelected = true;
            this.fieldselected = defaultSelected;
            this.fieldauditenabled = defaultSelected;
            
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
                    // Default to True
                        // fieldselected=false;
                        fieldselected = true;
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
            GRAXQuery__c graxq = gxs.getSynchedObject(ObjectName);
            if (graxq != null){
                disablesynch = false;
                defaultfilter = graxq.Filter__c;
                defaultprocessordering = graxq.Order_By__c;
                defaultfields = graxq.Selected_Fields__c;
                graxconfig = graxq.graxconfig__c;
                auditenabled = graxq.Enable_Audit_Log__c;
                string currentfields = ','+ graxq.Selected_Fields__c + ',';
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

        // objToQuery = '';
        return null;   
    }
    
    Public Pagereference Synchronize(){ 
        if (objToQuery!=null && objToQuery!=''){
	        SaveSelection();
	        System.debug('[GRAX.io] Processing History \"' + objToQuery + '\"');
        		GRAXBatch.ProcessHistory(objToQuery);
        		historyprocessed = true;
        }else{
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please Select Object.'));
        }
        return null;
    }

    // FLOW
    
    public string getPropURLToDisplay_Flow() { 
        String flowUrl = 'https://grax.io';
        if (gxs.graxConfig.GRAX_Flow_URL__c != null )
            flowUrl = gxs.graxConfig.GRAX_Flow_URL__c; 
        return flowUrl;
    }
    
    public pagereference connect(){
        pagereference p=new pagereference(getPropURLToDisplay_Flow());
        return p;
    }

    // COMMON
    public pagereference CancelReload() {
        pagereference pageRef = new pagereference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);

        return pageRef;
    }

}