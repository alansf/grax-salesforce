public class GRAXAuditTrail extends GRAXCloud {
	public String AuditConfig = '';
	public String ConnectionString = '';
	
    public String GetAuditSettings(String ConnString){
    		ConnectionString = ConnString;
    		String content = '{"connectionstring" : "' + ConnectionString + '"}';
    		GRAXSettings gxcSettings = new GRAXSettings();
    		String url = gxcSettings.ApiURL + '/platforms/heroku/postgres/getpartitionsize';
    		AuditConfig = GRAXCloud.calloutnow(url,content);
    		gxcSettings.debug('GRAXAuditTrail.GetAuditSettings',AuditConfig);
    		return AuditConfig;
    }
}
