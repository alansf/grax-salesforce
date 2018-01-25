public class GRAXConfiguration {

    List<FieldProperties> FieldProperties;
    public string objToQuery {get;set;}
     
    public string defaultfields {get;set;}
    public string defaultfilter {get;set;}
    public string defaultprocessordering {get;set;}
    
    public boolean enablesynch {get;set;}
      
    public GRAXConfiguration () { 
    }  
    
    public List<FieldProperties> getfieldProperties ()
    {
        FieldProperties= new List<FieldProperties>();
        SObjectType objType = Schema.getGlobalDescribe().get(objtoquery);
        if (objType != null)
        {
        Map<String,Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
        for (String s : fields.keySet()) 
             {
                if (fields.get(s).getDescribe().isAccessible()){
                		FieldProperties.add(new FieldProperties(objtoquery, s));
                }
             }
        }
        SynchSaved(objToQuery);
        return FieldProperties;
    }
    
   
    public List<SelectOption> getItems() 
    {
       string cobjname;
       List<SelectOption> options = new List<SelectOption>();
       List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();  
       for(Schema.SObjectType f : gd){
			cobjname = f.getDescribe().getName();
			options.add(new SelectOption(cobjname ,cobjname ));
       }  
       options.sort();
       return options;
    }
    
    public class FieldProperties
    {
        private string sObjtoquery;
        
        public string fieldname{get;set;}
        public string fieldtype{get;set;}
        public boolean fieldselected{get;set;}
        
        public FieldProperties() {}  
        
        public FieldProperties(string objname, string fieldname) {
            this.sObjtoquery = objname;
            this.fieldname = fieldname;
            this.fieldselected = false;
            getAttributes(objname, fieldname);
        }
    
        public void getAttributes(string objtoquery, string afieldname)
        {
          SObjectType objType = Schema.getGlobalDescribe().get(objtoquery);
          Map<String,Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
          if (fields.get(afieldname).getDescribe().isAccessible())
          {  
			fieldname = afieldname;
			fieldtype = string.valueof(fields.get(afieldname).getDescribe().getType());
			if (fieldtype=='REFERENCE' || fieldname=='name' || fieldname=='id'){
				fieldselected=true;
			}
          }
        }
    } 
    
    Public Pagereference QueryObject()
    {    return null;    }
    
    private void SynchSaved(String ObjectName){
    	    integer counter = 0;
    		List<GRAXQuery__c> query = [Select Id, Name, ObjectName__c,Selected_Fields__c,Order_By__c,Filter__c  From GRAXQuery__c where ObjectName__c=:ObjectName];
    		if (!query.isEmpty()){
    			enablesynch = false;
    			defaultfilter = query[0].Filter__c;
    			defaultprocessordering = query[0].Order_By__c;
    			defaultfields = query[0].Selected_Fields__c;
    			string currentfields = ','+ query[0].Selected_Fields__c + ',';
    			for(FieldProperties obj : FieldProperties){
    				if (currentfields.indexOf(',' + obj.fieldname + ',')>0){
    					FieldProperties[counter].fieldselected=true;
    				}
    				counter++;
    			}
    		}
    		else{
    			enablesynch = true;
    			SynchSelectedFields();
    		}
    }
    
    private void SynchSelectedFields(){
    		string fieldlist = '';
    		for(FieldProperties obj : FieldProperties){
    			if (obj!=null){
	    			if (obj.fieldselected){
	    				if (fieldlist!='')
	    					fieldlist+=',';
	    				fieldlist+=obj.fieldname;
	    			}
    			}
    		}
    		defaultfields = fieldlist;
    }
    
    Public Pagereference SaveSelection()
    {    
    		GRAXQuery__c newQuery = new GRAXQuery__c();
    		newQuery.ObjectName__c = objToQuery;
    		SynchSelectedFields();
    		newQuery.Selected_Fields__c = defaultfields;
    		newQuery.Order_By__c=defaultprocessordering;
    		newQuery.Filter__c=defaultfilter;
    		upsert newQuery ObjectName__c;
    		enablesynch = true;
    		return null;   
	}
	
	Public Pagereference Synchronize(){ 
		SaveSelection();
		GRAXBatch.ProcessHistory(objToQuery);
		return null;
    }
    
 }
