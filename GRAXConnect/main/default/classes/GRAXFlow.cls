public with sharing class GRAXFlow {
    public GRAXFlow() {

	    	if (GRAXSettings.IsConfigured()==false)
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please complete <a href="/one/one.app#/n/GRAX_DEPLOY">GRAX Configuration</a>.'));
    
    }
    
    public string getPropURLToDisplay() { 
    	    String flowUrl = 'https://grax.io';
    		GRAXSettings__c graxsettings = GRAXSettings__c.getOrgDefaults();
    		if (graxsettings.GRAX_Flow_URL__c!=null)
        		flowUrl = graxsettings.GRAX_Flow_URL__c; 
        return flowUrl;
    }
    
    public pagereference connect(){
        pagereference p=new pagereference(getPropURLToDisplay());
        return p;
    }
    
}
