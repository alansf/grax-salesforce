/* --------------------------------------------------------------------------
 * This file is subject to the terms and conditions defined in
 * file https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE,
 * which is part of this source code package.
 * --------------------------------------------------------------------------
 *          Copyright (c) 2017-2018 Harding Point
 *                  All rights reserved
 * --------------------------------------------------------------------------
 * Support: Support@Grax.io
 * Website: https://grax.io
 * Github:  https://github.com/HardingPoint/GRAXForSFDC
 * License: https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE
 * --------------------------------------------------------------------------*/

/*****************************************************************************************
Name              : GRAXApi
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       07/04/2018             
******************************************************************************************/
public class GRAXApi extends GRAXCloud {
    // -------------------------------------------------
    // https://grax.io
    // Support Contact - Support@Grax.io
    // -------------------------------------------------
	private static Boolean isArchive = false;
    
    public static String jsonContent(List<SObject> triggerNew, List<SObject> triggerOld) {
        return jsonContent(triggerNew,triggerOld,'');
    }

	public static String jsonContentArchive(List<SObject> triggerNew) {
    	isArchive = true;
        return jsonContent(triggerNew,null,'');
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
            String FilterFields = '';
            
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
            
            
            /*--------------------------------------------------*/
            
            if (gxcSettings.GRAXQuery!=null)
            		FilterFields = gxcSettings.GRAXQuery.Selected_Fields__c;
            		
            newObjects = JSON.serialize(triggerNew);

            if((Trigger.isExecuting && (Trigger.isInsert || Trigger.isUpdate)) || isArchive) {
                // Get list of reference fields to query
                List<String> referenceFields = GRAXUtils.getReferenceFields(ObjectType);

                if(referenceFields.size() > 0) {
                    // build the query to retrive same records including the name field of every lookup in the current object.
                    String strQuery = 'SELECT ' + String.join(referenceFields, ',') + ' FROM ' + ObjectType;
                    strQuery += ' WHERE Id IN :triggerNew';

                    Map<Id, SObject> recsMap = new Map<Id, SObject>(Database.query(strQuery));

                    List<Object> recList = (List<Object>)JSON.deserializeUntyped(newObjects);

                    // Iterate through the records retrived and add every reference field name to the JSON.
                    for(Object recObj : recList){
                        Map<String, Object> rec = (Map<String, Object>)recObj;

                        SObject so = recsMap.get((Id)rec.get('Id'));

                        for(String refFld : referenceFields) {
                            rec.put(refFld.replaceAll('\\.', '_'), GRAXUtils.parseSObjectFieldValue(so, refFld));
                        }
                    }

                    newObjects = JSON.serialize(recList);
                }
            }
            
            /* --------------------------------------------------   
            // If graxconfig is NOT null it has been passed in from outside a trigger and is correct
            if ((graxconfig != null && graxconfig != '') && triggerNew != null) {
                    gxcSettings.debug('GRAXCloud.jsonContent',' Called from GRAX Configuration');
                newObjects = JSON.serialize(triggerNew);
            }else if (triggerNew != null && (graxconfig == null || graxconfig == '') ){
                    gxcSettings.debug('GRAXCloud.jsonContent',' Called from Trigger');
                    if(gxcSettings.GRAXQuery == null){
                        newObjects = JSON.serialize(triggerNew);            
                    } else if(gxcSettings.GRAXQuery.Enable_Audit_Log__c == true){
                        FilterFields = gxcSettings.GRAXQuery.Selected_Fields__c;
                        newObjects = JSON.serialize(triggerNew);
                    }else{
                        // Pass filtered fields 
                        List<Id> Ids = GetIds(triggerNew);
                        if(Test.isRunningTest()) {
                            FilterFields = 'Id';
                        } else {
                            FilterFields = gxcSettings.GRAXQuery.Selected_Fields__c;
                        }
                        String Query = 'Select ' + FilterFields + ' FROM ' + ObjectType + ' Where Id in :Ids';
                        newObjects = JSON.serialize(Database.query(Query));
                    }         
            }
			--------------------------------------------------*/   
            
            if (graxconfig=='')
                    graxconfig = gxcSettings.GRAXQuery.graxconfig__c;
            
            if (triggerOld != null) {
                oldObjects = JSON.serialize(triggerOld);
            }
            
            String graxconfigsetting = '';
            if (graxconfig!=null && graxconfig!='')
                graxconfigsetting = '"graxconfig": ' + graxconfig + ',';

	        String s3settings = '';    
	        // Eventually should support object to region mapping
	        if (gxcSettings.GRAXQuery.Enable_Audit_Log__c == true && triggerNew != null && 
	        		gxcSettings.graxConfig.s3accesskeyid__c!='' && gxcSettings.graxConfig.s3secretaccesskey__c!='' ){
	        		s3settings = '"s3audit":"true",' + 
	        					 '"s3accesskeyid":"' + gxcSettings.graxConfig.s3accesskeyid__c + '",' + 
	        					 '"s3secretaccesskey":"' + gxcSettings.graxConfig.s3secretaccesskey__c + '",' + 
	        					 '"s3bucket":"' + gxcSettings.graxConfig.s3bucket__c + '",' + 
	        					 '"s3region":"' + gxcSettings.graxConfig.s3region__c + '",' + 
	        					 '"filterfields":"' + FilterFields + '",';
	        }
	        
	        String content = '{' + 
									'"archive": '+ (isArchive? 'true':'false') + ',' +
	        						'"orgId": "'+ UserInfo.getOrganizationId() + '",' +
	        						'"userId": ' + JSON.serialize(UserInfo.getUserId()) + ',' + 
	        						'"graphdburl": "' + gxcSettings.graphdburl + '",' + 
	        						'"postgresurl": "' + gxcSettings.PostgresURL + '",' + 
	        						s3settings +
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
        GRAXCloud.calloutnow(url, payload);
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