public class GraphConnect {
    public string getPropURLToDisplay() { 
        string URL = 'https://graphconnect.hardingpoint.com?sfdcdomain=https://' + URL.getSalesforceBaseUrl().getHost() + '/'; 
        return URL;
    }
    
    public pagereference connect(){
        pagereference p=new pagereference(getPropURLToDisplay());
        return p;
    }
}