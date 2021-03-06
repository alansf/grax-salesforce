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


public class GRAXConfiguration {

	    List<FieldProperties> FieldProperties;
	    Map<String,GRAXQuery__c> sychedObjectsSaved;
	    Map<String,String> RelatedToList;
	    
	    public string objToQuery {get;set;}
	     
	    public string defaultfields {get;set;}
	    public string defaultfilter {get;set;}
	    public string defaultprocessordering {get;set;}
	    
	    public string graxconfig {get;set;}
	    public boolean disablesynch {get;set;}
	    public boolean disablesave {get;set;}
	    public boolean historyprocessed {get;set;}
	    
	    public boolean isconfigured {get;set;}
	    public boolean auditenabled {get;set;}
	      
	    public GRAXConfiguration () {    
	    		isconfigured = GRAXSettings.IsConfigured();
	    		disablesave = true;
	    		if (isconfigured==false)
	    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please complete <a href="/one/one.app#/n/GRAX_DEPLOY">GRAX Configuration</a>.'));
	    		else{
	    			sychedObjectsSaved = getSynchedObjects();
		    		RelatedToList = new Map<String,String>();
	    		}
	    }
	    
	    public string getPropURLToDisplay() { 
	        string salesforceURL = 'https://graphconnect.hardingpoint.com?sfdcobject=' + objToQuery + '&sfdcdomain=https://' + URL.getSalesforceBaseUrl().getHost() + '/'; 
	        // string salesforceURL = 'https://graphconnect-test.herokuapp.com/?sfdcobject=' + objToQuery + '&sfdcdomain=https://' + URL.getSalesforceBaseUrl().getHost() + '/'; 
	        
	        return salesforceURL;
	    }
	    
	    public pagereference DeployTrigger(){
	        pagereference p=new pagereference(getPropURLToDisplay());
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
				}else if (fieldtype=='REFERENCE') {
					referenceto = string.valueof(fields.get(afieldname).getDescribe().getReferenceTo()).replace('(','').replace(')','');
					if (sychedObjectsSaved.get(referenceto)!=null || sychedObjectsSaved.get(referenceto.toLowerCase())!=null || referenceto.toLowerCase()==objToQuery.toLowerCase()){
						fieldselected=true;
						message = 'Synchronized';
					}else{
						fieldselected=false;
						disabled = true;
						message = 'Not Synchronized';
					}
				}
	          }
	        }
	    } 
	    
	    Public Pagereference QueryObject()
	    {    return null;    }
	    
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
		    		}
		    		else{
		    			disablesynch = true;
		    			defaultprocessordering = 'LastModifiedDate DESC';
		    			defaultfilter = '';
		    			auditenabled = false;
		    			// defaultfilter = 'CALENDAR_YEAR(LastModifiedDate) > 2016';
		    			SynchSelectedFields();
		    		}
	    	    }
	    	    else{
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
    
 }