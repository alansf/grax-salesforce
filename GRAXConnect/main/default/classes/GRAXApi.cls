public class GRAXApi {
    // -------------------------------------------------
    // https://grax.io
    // Support Contact - Support@Grax.io
    // -------------------------------------------------
    
    public static List<Object> NormalizeList(List<SObject> UpdateObjects){
    		if (UpdateObjects!=null){
    			if (!UpdateObjects.isEmpty()){
    				Integer counter = 0;
    				Schema.SObjectType sObjectType = UpdateObjects.getSObjectType();
    				String ObjectName = '' + sObjectType;
    				List<GRAXQuery__c> GRAXquery = [Select Id, Name, ObjectName__c,Selected_Fields__c,Order_By__c,Filter__c,graxconfig__c  From GRAXQuery__c where ObjectName__c=:ObjectName];
    				if (!GRAXquery.isEmpty()){
    					if (GRAXquery[0].Selected_Fields__c!=null){
    						String fieldList = ',' + GRAXquery[0].Selected_Fields__c.toLowerCase() + ',';
    						Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); Schema.SObjectType ctype = gd.get(ObjectName); 
    						Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();
    						for (String s : fmap.keySet()){
    							if (fieldList.indexOf(s.toLowerCase())==-1){
    								for (Integer i = 0; i < UpdateObjects.size(); i++) {
    									try{
    						 				UpdateObjects[i].put(s,null);
    						 				counter++;
    						 			}catch(Exception ex){}	
    						 		}
    							}
    						}
    						System.debug('[GRAX.io] Normalized: ' + counter + ' Values');
    					}
    				}
    			}
    		}
    		return UpdateObjects;
    }
    
    public static Boolean IsConfigured(){
    		Boolean returnvalue = false;
    		GRAXSettings__c graxConfig = GRAXSettings__c.getOrgDefaults();
    		if (graxConfig != null){
    			if ((graxConfig.graphdburl__c != null && graxConfig.graphdburl__c != '')&&			
    				(graxConfig.LicenseToken__c != null && graxConfig.LicenseToken__c != '')&&
    				(graxConfig.GatewayToken__c != null && graxConfig.GatewayToken__c != '')&&
    				(graxConfig.ApiToken__c != null && graxConfig.ApiToken__c != ''))
    				returnvalue = true;
    		}
    		
    		return returnvalue;
    }
    
    public static String NormalizeJSON(String jsonContent, String ObjectName){
    		// JSONParser parser = JSON.createParser(jsonContent);
    		return '';
    }
    
    public static String jsonContent(List<SObject> triggerNew, List<SObject> triggerOld) {
    		return jsonContent(triggerNew,triggerOld,'');
    }
 
    public static String jsonContent(List<SObject> triggerNew, List<SObject> triggerOld, String graxconfig) {

        String newObjects = '[]';
        
        if (triggerNew != null) {
            newObjects = JSON.serialize(triggerNew);
        }
        String oldObjects = '[]';
        if (triggerOld != null) {
            oldObjects = JSON.serialize(NormalizeList(triggerOld));
        }
        String userId = JSON.serialize(UserInfo.getUserId());
        GRAXSettings__c hpd = GRAXSettings__c.getOrgDefaults();

        // This is the URL for Neo4j
        // System.debug('graphdburl:' + hpd.graphdburl__c);
        String graphdburl = hpd.graphdburl__c;
        
		// 
		String graxconfigsetting = '';
        if (graxconfig!=null && graxconfig!='')
            graxconfigsetting = '"graxconfig": ' + graxconfig + ',';
		
        String content = '{' + 
        						'"orgId": "'+ UserInfo.getOrganizationId() + '",' +
        						'"userId": ' + userId + ',' + 
        						'"graphdburl": "' + graphdburl + '",' + 
        						graxconfigsetting + 
        						'"new": ' + newObjects + ',' + 
        						'"old": ' + oldObjects + 
        					'}';
        // String content = '{"new": ' + newObjects + ', "orgId": "'+ UserInfo.getOrganizationId() +  '", "userId": ' + userId + ', "graphdburl": "' + graphdburl + '"}';

        return content;
    }

    public static void calloutnow(String url, String content) {
        GRAXSettings__c hpd = GRAXSettings__c.getOrgDefaults();
        if (url!=null && hpd.LicenseToken__c != null && hpd.ApiToken__c != null && hpd.GatewayToken__c != null){
        		Http h = new Http();
        		HttpRequest req = new HttpRequest();
        		// ------------------------------
	        //  Use for Org Wide Override
	        // ------------------------------
	        //if (hpd.APIURL__c!=''){
	        //    req.setEndpoint(hpd.APIURL__c);
	        //}else{
	            req.setEndpoint(url);
	        //}
	        // ------------------------------
        		req.setMethod('POST');
        		req.setHeader('Content-Type', 'application/json');
        		req.setHeader('licensetoken',hpd.LicenseToken__c);
        		req.setHeader('authorizationToken', hpd.ApiToken__c);
        		req.setHeader('x-api-key', hpd.GatewayToken__c);
        		req.setHeader('sfdcorgid', UserInfo.getOrganizationId());
	        req.setBody(content);
	        h.send(req);
        }
    }

    @future(callout=true)
    public static void callout(String url, String content) {
        GRAXApi.calloutnow(url,content);
    }
    
    public static String graxconfig(String sobjectName){
    		String graxconfig ='';
    		if (sobjectName!='' && sobjectName!=null){
    			List<GRAXQuery__c> queries = [Select ObjectName__c, graxconfig__c  From GRAXQuery__c where ObjectName__c=:sobjectName];
			if (queries.size()>0){
				graxconfig = queries[0].graxconfig__c;
				System.debug('[GRAX.io] graxconfig: ' + graxconfig);
			}
    		}
		return graxconfig;
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