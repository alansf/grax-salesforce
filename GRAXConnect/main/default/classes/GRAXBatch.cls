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
        	    List<GRAXQuery__c> GRAXSavedQueries = [Select Id, Name, ObjectName__c,Selected_Fields__c,Order_By__c,Filter__c  From GRAXQuery__c where ObjectName__c=:ObjectName];
    			if (!GRAXSavedQueries.isEmpty()){
    				GRAXQuery__c GRAXSavedQuery = GRAXSavedQueries[0];
    				Query = 'SELECT ' + GRAXSavedQuery.Selected_Fields__c + ' FROM ' + GRAXSavedQuery.ObjectName__c;
    				if (GRAXSavedQuery.Filter__c!='')
    					Query+= ' WHERE ' + GRAXSavedQuery.Filter__c;
    				
    				if (GRAXSavedQuery.Order_By__c!='')
    					Query+= ' ORDER BY ' + GRAXSavedQuery.Order_By__c;
    			}
        		else
            		Query = BuildQuery(ObjectName);
        }
        CurrentObjectName = ObjectName;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Starting Batch Query: ' + Query);
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope){
        List<Object> triggerNew = new List<Object>();
        List<Object> triggerOld = new List<Object>();

        String url = 'https://prod.hardingpoint.com/v9.3/api';

        for (SObject currentObject : scope) {
            System.debug('Processing: ' + currentObject.Id);
            triggerNew.add(currentObject);
            recordsProcessed++;
        }
        GRAXApi.calloutnow(url,GRAXApi.jsonContent(triggerNew,triggerOld));
    }

    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' Records Synchronized. Harding Point Graph Synchronized for ' + CurrentObjectName);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];

        // CreatedBy.Email
        // call some utility to send email
        // EmailUtils.sendMessage(a, recordsProcessed);
    }

    public static void ProcessHistory(String ObjectName){
        GRAXBatch newbatch = new GRAXBatch(ObjectName);
        Database.executeBatch(newbatch, 10);
    }
}