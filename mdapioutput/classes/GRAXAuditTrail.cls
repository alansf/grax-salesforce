public class GRAXAuditTrail extends GRAXCloud {
	public GRAXCloud.CallOutResponse AuditConfig;
	public String ConnectionString = '';
	
	public Integer numberoftables = 0;
	public String schema = '';
	public String query = '';
	public String prefix = '';
	
    public String GetAuditSettings(String ConnString){
    		ConnectionString = ConnString;
    		String content = '{"connectionstring" : "' + ConnectionString + '"}';
    		GRAXSettings gxcSettings = new GRAXSettings();
    		String url = gxcSettings.ApiURL + '/platforms/heroku/postgres/getpartitionsize';
    		AuditConfig = GRAXCloud.calloutnow(url,content);
    		ParseConfig();
    		debug('GRAXAuditTrail.GetAuditSettings',AuditConfig.response);
    		return AuditConfig.response;
    }
    
    public void ParseConfig(){
    		if (AuditConfig.response!=''){
	    		schema = GetAppConfig('schema');
	    		query = GetAppConfig('query');
	    		prefix = GetAppConfig('prefix');
	    		numberoftables = Integer.valueof(GetAppConfig('numberoftables'));
    		}
    }
    
    private String GetAppConfig(String fieldName){
    		String ReturnValue = '';
    		if (AuditConfig.response!='' && AuditConfig.response!=null){
    			JSONParser parser = JSON.createParser(AuditConfig.response);
    			while (parser.nextToken() != null) {
    				if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == fieldName){
        				parser.nextToken();
        				ReturnValue = parser.getText();
        				debug('GRAXAuditTrail.GetAuditSettings',fieldName + '=' + ReturnValue);
        			}
        		}
    		}
    		return ReturnValue;
    }
    
    public String CreateAuditSettings(String ConnString,Integer NumberOfPartitions){
    		ConnectionString = ConnString;
    		String content = '{"connectionstring" : "' + ConnectionString + '","numberoftables":' + NumberOfPartitions + '}';
    		GRAXSettings gxcSettings = new GRAXSettings();
    		String url = gxcSettings.ApiURL + '/platforms/heroku/postgres/auditinstall';
    		AuditConfig = GRAXCloud.calloutnow(url,content);
    		ParseConfig();
    		debug('GRAXAuditTrail.GetAuditSettings',AuditConfig.response);
    		return AuditConfig.response;
    }
    
    public String DropAuditParitions(String ConnString,Integer NumberOfPartitions){
    		ConnectionString = ConnString;
    		String content = '{"connectionstring" : "' + ConnectionString + '","numberoftables":' + NumberOfPartitions + '}';
    		GRAXSettings gxcSettings = new GRAXSettings();
    		String url = gxcSettings.ApiURL + '/platforms/heroku/postgres/audituninstall';
    		AuditConfig = GRAXCloud.calloutnow(url,content);
    		ParseConfig();
    		debug('GRAXAuditTrail.DropAuditParitions',AuditConfig.response);
    		return AuditConfig.response;
    }
    
}
