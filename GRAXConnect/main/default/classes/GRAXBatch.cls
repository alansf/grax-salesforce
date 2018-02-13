global class GRAXBatch implements
    Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Integer recordLimit = 200;
    global String Query = '';
    global String CurrentObjectName = '';

    string BuildQuery(string ObjectName){     
        string BuildQuery = '';
        
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
        return Query;
    }

    global GRAXBatch(String ObjectName){
        if (ObjectName!=''){
        	    List<GRAXQuery__c> GRAXSavedQueries = [Select Id, Name, ObjectName__c,Selected_Fields__c,Order_By__c,Filter__c, Last_Synch__c  From GRAXQuery__c where ObjectName__c=:ObjectName];
    			if (!GRAXSavedQueries.isEmpty()){
    				GRAXQuery__c GRAXSavedQuery = GRAXSavedQueries[0];
    				
    				Query = 'SELECT ' + GRAXSavedQuery.Selected_Fields__c + ' FROM ' + GRAXSavedQuery.ObjectName__c;
    				
    				String WhereClause = '';
    				if (GRAXSavedQuery.Filter__c!='' && GRAXSavedQuery.Filter__c!=null)
    					WhereClause = GRAXSavedQuery.Filter__c;
    				
    				if (GRAXSavedQuery.Last_Synch__c != null){
    					if (WhereClause!='')
    						WhereClause += ' AND ';
    						
    					DateTime lastSynch = GRAXSavedQuery.Last_Synch__c;
    					WhereClause += '	lastmodifieddate >= ' + lastSynch.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    				}	
    				
    				if (WhereClause != '')
    					Query+= ' WHERE ' + WhereClause;
    				
    				if (GRAXSavedQuery.Order_By__c!='' && GRAXSavedQuery.Order_By__c!=null)
    					Query+= ' ORDER BY ' + GRAXSavedQuery.Order_By__c;
    			}
        		else
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

        String url = 'https://prod.hardingpoint.com/v9.3/api';
        String graxconfig ='';
        if (scope.size()>0){
        		SObject obj = scope[0];
        		String ObjectName = string.valueof(obj.getSObjectType());
        		
        		List<GRAXQuery__c> queries = [Select ObjectName__c,graxconfig__c  From GRAXQuery__c where ObjectName__c=:ObjectName];
        		if (queries.size()>0)
        			graxconfig = queries[0].graxconfig__c;
        			
        		System.debug('[GRAX.io] graxconfig: ' + graxconfig);
        }

        for (SObject currentObject : scope) {
            System.debug('[GRAX.io] Processing: ' + currentObject.Id);
            triggerNew.add(currentObject);
            recordsProcessed++;
        }
        GRAXApi.calloutnow(url,GRAXApi.jsonContent(triggerNew,triggerOld,graxconfig));
    }

    global void finish(Database.BatchableContext bc){
        System.debug('[GRAX.io] ' + recordsProcessed + ' Records Synchronized for ' + CurrentObjectName);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];

		List<GRAXQuery__c> queries = [Select ObjectName__c,Last_Synch__c,Total_Records_Processed__c From GRAXQuery__c where ObjectName__c=:CurrentObjectName];
		if (queries.size()>0){
			queries[0].Last_Synch__c = Datetime.now();
			if (queries[0].Total_Records_Processed__c==null)
				queries[0].Total_Records_Processed__c = 0;
			
			queries[0].Total_Records_Processed__c = queries[0].Total_Records_Processed__c + recordsProcessed;
			update queries;
		} 
    }

    public static void ProcessHistory(String ObjectName){
        GRAXBatch newbatch = new GRAXBatch(ObjectName);
        Database.executeBatch(newbatch, 100);
    }
    
}