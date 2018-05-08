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

public virtual class GRAXSettings {

	public Boolean ProperlyConfigured = false; 
	public String graphdburl = '';
	public String LicenseToken = '';
	public String GatewayToken = '';
	public String ApiToken = '';
	public String PostgresURL = '';
	
	public GRAXSettings__c graxConfig {get;set;}
	
	// Default to the testing URL
	public String ApiURL = 'https://test.hardingpoint.com/v9.3/api';
	public String GRAXDeployURL = 'https://heroku.com/deploy?template=https://github.com/HardingPoint/GRAXEnterprise/blob/master';

	public Boolean isObjectConfigured = false;
	
	// GRAX Saved Query List
	public Map<String,GRAXQuery__c> SynchedObjects = null;
	
	// GRAX Saved Query Singular
	public GRAXQuery__c GRAXQuery = null;
	
	private String ExecutionSource = '';

	public GRAXSettings(String executionSource, String objectName) {
		ExecutionSource = executionSource;
		ProperlyConfigured = Initialize(objectName);
	}

	// Load Settings for Object
	public GRAXSettings(String objectName) {
		ProperlyConfigured = Initialize(objectName);
	}

	// Default Constructor
    public GRAXSettings() {
		ProperlyConfigured = Initialize('');
    }
    
    public void UpdateSettings(){	
    		upsert graxConfig;
    }
    
    // Load the configuration & object settings.
    private Boolean Initialize(String ObjectName){
    		graxConfig = GRAXSettings__c.getOrgDefaults();
		if (graxConfig != null){
			// GRAX Custom Settings Values.
			graphdburl = graxConfig.graphdburl__c;
			LicenseToken = graxConfig.LicenseToken__c;
			GatewayToken = graxConfig.GatewayToken__c;
			PostgresURL = graxConfig.Postgres_URL__c;
			ApiToken = graxConfig.ApiToken__c;
			
			if (graxConfig.GRAX_API_Url__c != '' && graxConfig.GRAX_API_Url__c != null)
				ApiURL=graxConfig.GRAX_API_Url__c;
			
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
	    		List<GRAXQuery__c> queries = [Select Id,Name,Filter__c,GRAX_Configured__c,graxconfig__c,Hourly_Synch_Period__c,Last_Synch__c,ObjectName__c,Order_By__c,Selected_Fields__c,Total_Records_Processed__c,Enable_Audit_Log__c  From GRAXQuery__c];
	    		for (GRAXQuery__c query : queries){
	    			GRAXObjects.put(query.ObjectName__c,query);
	    		}
	    		return GRAXObjects;
	}
	
	// ------------------------------------------------------------------------
	// Should move these to a seperate class
	public void debug(String output){
    		debug('', output, '');
    }
    
    public void debug(String MethodName, String output){
    		debug(MethodName, output, '');
    }
    
    public void debug(String MethodName, String output, String Error){
    		String Source = ExecutionSource;
    		if (Source!='' && MethodName!='')
    			Source += '.' + MethodName;
    		else if (MethodName!='')
    			Source = MethodName;
    		GRAXSettings.debug(Source, output, Error, 0);
    }
    
    public static void debug(String source, String output, String error, Integer level){
    		if (Source!='')
    			Source += ': ';
    		if (error!='')
    			error = ' [GRAX Error] ' + error;
    			
    		System.debug('[GRAX.io] ' + source + output + error);
    }
    // ------------------------------------------------------------------------
}
