global class GRAXBatch implements
    Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Integer recordLimit = 200;
    
    global String Query = '';
    global String CurrentObjectName = '';
    
    global GRAXSettings gxcSettings = null;

    string BuildQuery(string ObjectName){     
        string BuildQuery = '';
        
        if (!gxcSettings.isObjectConfigured)
        		gxcSettings = new GRAXSettings(ObjectName);
        
        if (!gxcSettings.isObjectConfigured){
        		// ------------------------------------------------------
        		// This should NEVER happen
        		SObjectType t = Schema.getGlobalDescribe().get(ObjectName);
	        SObject o = t.newSobject();
	        Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();
	        for (String fieldName : m.keySet()) {
	            if (BuildQuery!=''){
	                BuildQuery+=',';
	            }
	          BuildQuery += fieldName;
	        }
	
	        if (BuildQuery!=''){
	            // Query = 'Select ' + BuildQuery + ' From ' + ObjectName + ' LIMIT ' + recordLimit;
	            Query = 'Select ' + BuildQuery + ' From ' + ObjectName;
	        }
	        // ------------------------------------------------------
        }else{
        		Query = 'SELECT ' + gxcSettings.GRAXQuery.Selected_Fields__c + ' FROM ' + gxcSettings.GRAXQuery.ObjectName__c;
    			String WhereClause = '';
    			if (gxcSettings.GRAXQuery.Filter__c!='' && gxcSettings.GRAXQuery.Filter__c!=null)
    				WhereClause = gxcSettings.GRAXQuery.Filter__c;
    				
    			if (gxcSettings.GRAXQuery.Last_Synch__c != null){
    				if (WhereClause!='')
    					WhereClause += ' AND ';
    						
    				DateTime lastSynch = gxcSettings.GRAXQuery.Last_Synch__c;
    				WhereClause += '	lastmodifieddate >= ' + lastSynch.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    			}	
    				
    			if (WhereClause != '')
    				Query+= ' WHERE ' + WhereClause;
    				
    			if (gxcSettings.GRAXQuery.Order_By__c!='' && gxcSettings.GRAXQuery.Order_By__c!=null)
    				Query+= ' ORDER BY ' + gxcSettings.GRAXQuery.Order_By__c;
        }
        return Query;
    }

    global GRAXBatch(String ObjectName){
        if (ObjectName!=''){
        		gxcSettings = new GRAXSettings(ObjectName);
        		Query = BuildQuery(ObjectName);
        }
        CurrentObjectName = ObjectName;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('[GRAX.io] Starting Batch Query: ' + Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope){
        List<SObject> triggerNew = new List<SObject>();
        List<SObject> triggerOld = new List<SObject>();

        String graxconfig ='';
        
        if (scope.size()>0){
        
        		SObject obj = scope[0];
        		String ObjectName = string.valueof(obj.getSObjectType());
        		
    			if (gxcSettings.isObjectConfigured){
    				graxconfig = gxcSettings.GRAXQuery.graxconfig__c;
    				System.debug('[GRAX.io] graxconfig: ' + graxconfig);
    			}    
    			
    			for (SObject currentObject : scope) {
            		System.debug('[GRAX.io] Processing: ' + currentObject.Id);
            		triggerNew.add(currentObject);
            		recordsProcessed++;
        		}
        		
        		System.debug('[GRAX.io] gxcSettings.ApiURL: ' + gxcSettings.ApiURL);
        		System.debug('[GRAX.io] triggerNew: ' + JSON.serialize(triggerNew));
        		System.debug('[GRAX.io] graxconfig: ' + JSON.serialize(graxconfig));
        		
        		GRAXApi.calloutnow(gxcSettings.ApiURL,GRAXApi.jsonContent(triggerNew,triggerOld,graxconfig));    		
        }        
    }

    global void finish(Database.BatchableContext bc){
        System.debug('[GRAX.io] ' + recordsProcessed + ' Records Synchronized for ' + CurrentObjectName);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];

		if (gxcSettings.isObjectConfigured){
			gxcSettings.GRAXQuery.Last_Synch__c = Datetime.now();
			if (gxcSettings.GRAXQuery.Total_Records_Processed__c==null)
				gxcSettings.GRAXQuery.Total_Records_Processed__c = 0;
			
			gxcSettings.GRAXQuery.Total_Records_Processed__c = gxcSettings.GRAXQuery.Total_Records_Processed__c + recordsProcessed;
			update gxcSettings.GRAXQuery;
		} 
    }

    public static void ProcessHistory(String ObjectName){
        GRAXBatch newbatch = new GRAXBatch(ObjectName);
        Database.executeBatch(newbatch, 100);
    }
    
}