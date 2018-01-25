public class GRAXConfiguration {

    List<FieldProperties> FieldProperties;
    public string objToQuery {get;set;}
     
    public string defaultfields {get;set;}
    public string defaultfilter {get;set;}
    public string defaultprocessordering {get;set;}
      
    public GRAXConfiguration () { 
    		defaultprocessordering = 'LastUpdated DESC';
    		defaultfilter = '';
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
    
    Public Pagereference SaveSelection()
    {    
    		GRAXQuery__c newQuery = new GRAXQuery__c();
    		newQuery.ObjectName__c = objToQuery;
    		
    		string fieldlist = '';
    		for(FieldProperties obj : FieldProperties){
    			if (obj.fieldselected){
    				if (fieldlist!='')
    					fieldlist+=',';
    				fieldlist+=obj.fieldname;
    			}
    		}
    		defaultfields = fieldlist;
    		newQuery.Selected_Fields__c = defaultfields;
    		newQuery.Order_By__c=defaultprocessordering;
    		newQuery.Filter__c=defaultfilter;
    		upsert newQuery ObjectName__c;
    		
    		return null;   
	}
    
 }
