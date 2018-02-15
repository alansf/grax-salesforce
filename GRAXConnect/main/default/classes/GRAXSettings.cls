public virtual with sharing class GRAXSettings {

	public Boolean ProperlyConfigured = false; 
	public String graphdburl = '';
	public String LicenseToken = '';
	public String GatewayToken = '';
	public String ApiToken = '';

	public Boolean isObjectConfigured = false;
	
	// GRAX Saved Query List
	public Map<String,GRAXQuery__c> SynchedObjects = null;
	
	// GRAX Saved Query Singular
	public GRAXQuery__c GRAXQuery = null;

	// Load Settings for Object
	public GRAXSettings(String objectName) {
		ProperlyConfigured = Initialize(objectName);
	}

	// Default Constructor
    public GRAXSettings() {
		ProperlyConfigured = Initialize('');
    }
    
    // Load the configuration & object settings.
    private Boolean Initialize(String ObjectName){
    		GRAXSettings__c graxConfig = GRAXSettings__c.getOrgDefaults();
		if (graxConfig != null){
			// GRAX Custom Settings Values.
			graphdburl = graxConfig.graphdburl__c;
			LicenseToken = graxConfig.LicenseToken__c;
			GatewayToken = graxConfig.GatewayToken__c;
			ApiToken = graxConfig.ApiToken__c;
			
    			if ((graphdburl != null && graphdburl != '')&&			
    				(LicenseToken != null && LicenseToken != '')&&
    				(GatewayToken != null && GatewayToken != '')&&
    				(ApiToken != null && ApiToken != ''))
    				ProperlyConfigured = true;
    		}
    		
    		// GRAX Saved Queries
		SynchedObjects = GRAXSettings.getSynchedObjects();
		
    		GRAXQuery = getSynchedObject(ObjectName);
    		if (GRAXQuery!=null){
    			isObjectConfigured = true;
    		}
    				
    		return ProperlyConfigured;
    }
    
    public static Boolean IsConfigured(){
    		GRAXSettings gx = new GRAXSettings();
    		return gx.ProperlyConfigured;
    }
    
    public GRAXQuery__c getSynchedObject(String ObjectName){
    		if (ObjectName!='')
    			return SynchedObjects.get(ObjectName);
    		else
    			return null;
    }
    
    // Singular place to load settings. If the schema changes this is where you modify it.
    public static Map<String,GRAXQuery__c> getSynchedObjects()
	{
	    		Map<String,GRAXQuery__c> GRAXObjects = new Map<String,GRAXQuery__c>();
	    		List<GRAXQuery__c> queries = [Select Id,Name,Filter__c,GRAX_Configured__c,graxconfig__c,Hourly_Synch_Period__c,Last_Synch__c,ObjectName__c,Order_By__c,Selected_Fields__c,Total_Records_Processed__c  From GRAXQuery__c];
	    		for (GRAXQuery__c query : queries){
	    			GRAXObjects.put(query.ObjectName__c,query);
	    		}
	    		return GRAXObjects;
	}
    
}
