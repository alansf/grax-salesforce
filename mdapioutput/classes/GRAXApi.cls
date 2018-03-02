public class GRAXApi extends GRAXCloud {
    // -------------------------------------------------
    // https://grax.io
    // Support Contact - Support@Grax.io
    // -------------------------------------------------
    
    public static String jsonContent(List<SObject> triggerNew, List<SObject> triggerOld) {
    		return jsonContent(triggerNew,triggerOld,'');
    }
    
    // Gets a list of Ids
    public static List<Id> GetIds(List<SObject> sObjects){
	    List<Id> ids = new List<Id>();
	    for(SObject sObj : sObjects){
	        ids.add(sObj.Id);
	    }
	    return ids;
	}
 
    public static String jsonContent(List<SObject> triggerNew, List<SObject> triggerOld, String graxconfig) {

		if (triggerNew != null || triggerOld != null){
			String newObjects = '[]';
	        String oldObjects = '[]';
	        String Operation = '';
	        
	        Schema.SObjectType sObjectType;
	        if (triggerNew != null){
	        		Operation = 'Insert Operation';
	        		sObjectType = triggerNew.getSObjectType();
	        	}else if (triggerOld != null){
	        		Operation = 'Delete Operation';
	        		sObjectType = triggerOld.getSObjectType();
	        	}
	        
	    		String ObjectType = '' + sObjectType;
	        	GRAXSettings gxcSettings = new GRAXSettings(ObjectType);
	        
	        gxcSettings.debug('GRAXCloud.jsonContent',Operation + ' : ObjectType=' + ObjectType);
	        
	        // If graxconfig is NOT null it has been passed in from outside a trigger and is correct
	        if ((graxconfig != null && graxconfig != '') && triggerNew != null) {
	        		gxcSettings.debug('GRAXCloud.jsonContent',' Called from GRAX Configuration');
	            newObjects = JSON.serialize(triggerNew);
	        }else if (triggerNew != null && (graxconfig == null || graxconfig == '') ){
	        		gxcSettings.debug('GRAXCloud.jsonContent',' Called from Trigger');
	        		List<Id> Ids = GetIds(triggerNew);
	        		String Query = 'Select ' + gxcSettings.GRAXQuery.Selected_Fields__c + ' FROM ' + ObjectType + ' Where Id in :Ids';
	        		newObjects = JSON.serialize(Database.query(Query));
	        }
	        
	        if (graxconfig=='')
	        		graxconfig = gxcSettings.GRAXQuery.graxconfig__c;
	        
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
		}else{
			GRAXSettings.debug('GRAXCloud.jsonContent','Both Lists Empty, should never happen','ERROR triggerNew==null && triggerOld==null', 0);
			return '{}';
		}
        
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
		GRAXCloud.callout(url,payload);
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