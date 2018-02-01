public with sharing class GRAXFlow {
    public GRAXFlow() {

    }
    
    public string getPropURLToDisplay() { 
        string salesforceURL = 'https://grax.io'; 
        return salesforceURL;
    }
    
    public pagereference connect(){
        pagereference p=new pagereference(getPropURLToDisplay());
        return p;
    }
    
}
