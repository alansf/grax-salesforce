public class GRAXApi extends GRAXCloud {
    // -------------------------------------------------
    // https://grax.io
    // Support Contact - Support@Grax.io
    // -------------------------------------------------
    
    public static String jsonContent(List<SObject> triggerNew, List<SObject> triggerOld) {
    		return jsonContent(triggerNew,triggerOld,'');
    }
    
    public static List<Id> GetIds(List<SObject> sObjects){
	    List<Id> ids = new List<Id>();
	    for(SObject sObj : sObjects){
	        ids.add(sObj.Id);
	    }
	    return ids;
	}
 
    public static String jsonContent(List<SObject> triggerNew, List<SObject> triggerOld, String graxconfig) {

        String newObjects = '[]';
        String oldObjects = '[]';
        
        Schema.SObjectType sObjectType = triggerNew.getSObjectType();
    		String ObjectType = '' + sObjectType;
        	GRAXSettings gxcSettings = new GRAXSettings(ObjectType);
        
        if (triggerNew != null && graxconfig!='') {
            newObjects = JSON.serialize(triggerNew);
        }else{
        		List<Id> Ids = GetIds(triggerNew);
        		String Query = 'Select ' + gxcSettings.GRAXQuery.Selected_Fields__c + ' FROM ' + ObjectType + ' Where Id in :Ids';
        		newObjects = JSON.serialize(Database.query(Query));
        		graxconfig = gxcSettings.GRAXQuery.graxconfig__c;
        }
        
        if (triggerOld != null) {
            oldObjects = JSON.serialize(triggerOld);
        }
        
		String graxconfigsetting = '';
        if (graxconfig!=null && graxconfig!='')
            graxconfigsetting = '"graxconfig": ' + graxconfig + ',';
		
        String content = '{' + 
        						'"orgId": "'+ UserInfo.getOrganizationId() + '",' +
        						'"userId": ' + JSON.serialize(UserInfo.getUserId()) + ',' + 
        						'"graphdburl": "' + gxcSettings.graphdburl + '",' + 
        						graxconfigsetting + 
        						'"new": ' + newObjects + ',' + 
        						'"old": ' + oldObjects + 
        					'}';        

        return content;
    }
    
    public static String graxconfig(String sobjectName){
    		GRAXSettings gxcSettings = new GRAXSettings(sobjectName);
    		if (gxcSettings.isObjectConfigured)	
			return gxcSettings.GRAXQuery.graxconfig__c;
		else
			return '';
    }

	public static void cloudconfig(String sobjectName){
		GRAXSettings gxcSettings = new GRAXSettings(sobjectName);
		String url = gxcSettings.ApiURL + '/applications/neo4j/configure';
		String payload = '{' +
				'"sfdcorgid": "'+ UserInfo.getOrganizationId() + '",' +
				'"userId": "' + UserInfo.getUserId() + '",' + 
				'"sfdcobjectname": "' + sobjectName + '",' +
				'"graphdburl": "' + gxcSettings.graphdburl + '"' +
			'}';
		GRAXApi.callout(url,payload);
	}

    public static SObject mock(String sobjectName) {
        SObjectType t = Schema.getGlobalDescribe().get(sobjectName);

        SObject o = t.newSobject();

        Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();

        for (String fieldName : m.keySet()) {
        DescribeFieldResult f = m.get(fieldName).getDescribe();
        if (!f.isNillable() && f.isCreateable() && !f.isDefaultedOnCreate()) {
        if (f.getType() == DisplayType.Boolean) {
            o.put(f.getName(), false);
            }
            else if (f.getType() == DisplayType.Currency) {
                o.put(f.getName(), 0);
            }
            else if (f.getType() == DisplayType.Date) {
                o.put(f.getName(), Date.today());
            }
            else if (f.getType() == DisplayType.DateTime) {
                o.put(f.getName(), System.now());
            }
            else if (f.getType() == DisplayType.Double) {
                o.put(f.getName(), 0.0);
            }
            else if (f.getType() == DisplayType.Email) {
                o.put(f.getName(), 'foo@foo.com');
            }
            else if (f.getType() == DisplayType.Integer) {
                o.put(f.getName(), 0);
            }
            else if (f.getType() == DisplayType.Percent) {
                o.put(f.getName(), 0);
            }
            else if (f.getType() == DisplayType.Phone) {
                o.put(f.getName(), '555-555-1212');
            }
            else if (f.getType() == DisplayType.String) {
                o.put(f.getName(), 'TEST');
            }
            else if (f.getType() == DisplayType.TextArea) {
                o.put(f.getName(), 'TEST');
            }
            else if (f.getType() == DisplayType.Time) {
                o.put(f.getName(), System.now().time());
            }
            else if (f.getType() == DisplayType.URL) {
                o.put(f.getName(), 'http://foo.com');
            }
            else if (f.getType() == DisplayType.PickList) {
                o.put(f.getName(), f.getPicklistValues()[0].getValue());
            }
        }
    }
    return o;
    }
}