	public class GRAXConfiguration {

	    List<FieldProperties> FieldProperties;
	    Map<String,GRAXQuery__c> sychedObjectsSaved;
	    Map<String,String> RelatedToList;
	    
	    public string objToQuery {get;set;}
	     
	    public string defaultfields {get;set;}
	    public string defaultfilter {get;set;}
	    public string defaultprocessordering {get;set;}
	    
	    public string graxconfig {get;set;}
	    public boolean enablesynch {get;set;}
	    public boolean isconfigured {get;set;}
	      
	    public GRAXConfiguration () {     		
	    	
	    		sychedObjectsSaved = getSynchedObjects();
	    		RelatedToList = new Map<String,String>();
	    		isconfigured = GRAXApi.IsConfigured();
	
	    		if (isconfigured==false)
	    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, '<a href="/one/one.app#/setup/CustomSettings/home">GRAX Settings Incomplete</a>'));
	    }
	    
	    public string getPropURLToDisplay() { 
	        string salesforceURL = 'https://graphconnect.hardingpoint.com?sfdcdomain=https://' + URL.getSalesforceBaseUrl().getHost() + '/'; 
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
	    
	    public List<FieldProperties> getfieldProperties ()
	    {
	    		String fieldName;
	        FieldProperties= new List<FieldProperties>();
	        SObjectType objType = Schema.getGlobalDescribe().get(objtoquery);
	        if (objType != null)
	        {
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
	        
	       // ------------------------------------------------------------------
	       /* Breaks for > 1000
	       string cobjname;
	       List<SelectOption> options = new List<SelectOption>();
	       List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();  
	       for(Schema.SObjectType f : gd){
	            cobjname = f.getDescribe().getName();
	            options.add(new SelectOption(cobjname ,cobjname ));
	       }  
	       */
	       // ------------------------------------------------------------------
	       
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
	    	    integer counter = 0;
	    	    
	    	    GRAXSettings gxs = new GRAXSettings(ObjectName);
	    		if (gxs.isObjectConfigured){
	    			enablesynch = false;
	    			defaultfilter = gxs.GRAXQuery.Filter__c;
	    			defaultprocessordering = gxs.GRAXQuery.Order_By__c;
	    			defaultfields = gxs.GRAXQuery.Selected_Fields__c;
	    			graxconfig = gxs.GRAXQuery.graxconfig__c;
	    			string currentfields = ','+ gxs.GRAXQuery.Selected_Fields__c + ',';
	    			for(FieldProperties obj : FieldProperties){
	    				if (currentfields.indexOf(',' + obj.fieldname + ',') >0 ){
	    					FieldProperties[counter].fieldselected=true;
	    				}
	    				counter++;
	    			}
	    		}
	    		else{
	    			enablesynch = true;
	    			defaultprocessordering = 'LastModifiedDate DESC';
	    			defaultfilter = 'CALENDAR_YEAR(LastModifiedDate) > 2016';
	    			SynchSelectedFields();
	    		}
	    }
	    
	    private void SynchSelectedFields(){
	    		string fieldlist = ''; 		 
	    		List<FieldProperties> SelectedProperties = new List<FieldProperties>();
	    		for(FieldProperties obj : FieldProperties){
	    			if (obj!=null){
		    			if (obj.fieldselected){
		    				SelectedProperties.add(obj);
		    				if (obj.referenceto!=null)
		    					RelatedToList.put(obj.fieldname, obj.referenceto);
		    					
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
	    		newQuery.GRAX_Configured__c=Datetime.now();
	    		upsert newQuery ObjectName__c;
	    		sychedObjectsSaved = getSynchedObjects();
	    		enablesynch = true;
	    		return null;   
		}
		
		Public Pagereference Synchronize(){ 
			SaveSelection();
			GRAXBatch.ProcessHistory(objToQuery);
			return null;
	    }
    
 }