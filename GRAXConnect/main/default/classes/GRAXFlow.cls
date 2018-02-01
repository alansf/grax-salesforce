public with sharing class GRAXFlow {
    public GRAXFlow() {

    }
    
    public string getPropURLToDisplay() { 
    	    String flowUrl = 'https://grax.io';
    		GRAXSettings__c graxsettings = GRAXSettings__c.getOrgDefaults();
    		if (graxsettings.GRAX_Flow_URL__c==null)
        		flowUrl = graxsettings.GRAX_Flow_URL__c; 
        return flowUrl;
    }
    
    public pagereference connect(){
        pagereference p=new pagereference(getPropURLToDisplay());
        return p;
    }
    
}
