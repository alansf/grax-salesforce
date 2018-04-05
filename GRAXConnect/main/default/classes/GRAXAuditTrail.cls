/* --------------------------------------------------------------------------
 * This file is subject to the terms and conditions defined in
 * file https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE,
 * which is part of this source code package.
 * --------------------------------------------------------------------------
 *          Copyright (c) 2017-2018 Harding Point
 *                  All rights reserved
 * --------------------------------------------------------------------------
 * Support:	Support@Grax.io
 * Website:	https://grax.io
 * Github:	https://github.com/HardingPoint/GRAXForSFDC
 * License:	https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE
 * --------------------------------------------------------------------------*/

// Future home when we can push for resolution with Salesforce
public class GRAXAuditTrail extends GRAXCloud{
    public GRAXAuditTrail() {
		
    }
    /*
    // This is not supported wish it was. Leaving for future as insertion via OData connector.
    public static String GetObjectType(List<SObject> sobjectList){
    		Schema.SObjectType sObjectType;
    		sObjectType = sobjectList.getSObjectType();
    		String ObjectType = '' + sObjectType;
    		return ObjectType;
    }
    
    public static List<SObject> CreateAuditRecords(List<SObject> triggerNew, List<SObject> triggerOld, String graxconfig){
    		string GRAXAuditName = 'grax_auditlog__x';
    		sObject sObj = null;
    		List<SObject> auditLogs = null;
    		integer counter = 0;
    		try{
    			sObj = Schema.getGlobalDescribe().get(GRAXAuditName).newSObject();
    			if (sObj != null){
    				auditLogs = new List<SObject>();
	    			string sCurrentObjectType = GetObjectType(triggerNew);
	    			SObjectType t = Schema.getGlobalDescribe().get(sCurrentObjectType);
	        		SObject o = t.newSobject();
	        		Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();
	        		for (String fieldName : m.keySet()) {
	        			System.debug('[GRAX.io] Audit Field : ' + fieldName);
	        			counter = 0;
	        			for (SObject newObject : triggerNew) {
	        				if (newObject.get(fieldName) != triggerOld[counter].get(fieldName)){
	        					sObj = Schema.getGlobalDescribe().get(GRAXAuditName).newSObject();
	        					sObj.put('updatedbyid__c',newObject.get('LastModifiedById'));
	        					sObj.put('objectid__c',newObject.get('Id'));
	        					sObj.put('objecttype__c',sCurrentObjectType);
	        					sObj.put('fieldupdated__c',fieldName);
	        					sObj.put('newvalue__c',string.valueof(newObject.get(fieldName)));
	        					sObj.put('oldvalue__c',string.valueof(triggerOld[counter].get(fieldName)));
	        					// sObj.put('updatedate__c',string.valueof(newObject.get('LastModifiedDate')));
	        					auditLogs.add(sObj);
	        					System.debug('[GRAX.io] Audit Changed : ' + fieldName + ' Change Log ' + auditLogs.size());
	        				}
	        				counter++;
	        			}
	        		}
	        		
	        		System.debug('[GRAX.io] Complete! : ' + auditLogs.size());
	        		if (auditLogs.size() > 0){
	        			System.debug('[GRAX.io] Audit Logs : ' + auditLogs.size());
	        			// THIS IS NOT SUPPORTED!
	        			// insert auditLogs;
	        		}else{
	        			System.debug('[GRAX.io] Audit Logs - No Change : ' + auditLogs.size());
	        		}	
    			}
    		}catch(GRAXException ex){
    			System.debug('[GRAX.io] Exception Error ' + ex);
    		}
    		return auditLogs;
    }
    */
}
