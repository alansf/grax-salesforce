public class GRAXConnect {
    public string getPropURLToDisplay() { 
        string salesforceURL = 'https://graphconnect.hardingpoint.com?sfdcdomain=https://' + URL.getSalesforceBaseUrl().getHost() + '/'; 
        return salesforceURL;
    }
    
    public pagereference connect(){
        pagereference p=new pagereference(getPropURLToDisplay());
        return p;
    }
}