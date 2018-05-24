/*****************************************************************************************
Name              : GRAXBatchToProcessSchedJob
Description       : This batch process executes a GRAX Schedule Process job, calling itself object by object as defined in the selected hierarchy
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Ariel Yankelevich       04/26/2018           David Mackey        GRAX Audit Trail Process (https://app.asana.com/0/326600806074978/633149554508926/f)
******************************************************************************************/
global class GRAXBatchToProcessSchedJob implements Database.Batchable<sObject>, Database.Stateful{
    public String query = '';
    public List<GRAXBackupCtrl.ObjRelStructure> objects2Process;
    public Integer currentElementIndex;
    public String currentJobId;
    public String currentSelectCriteria;
    public String currentObjRelStrucUniqueKey;
    public Integer maxParentIds2ProcessByChildIteration = 5000;
    public List<Id> parentIds2ProcessForChild;
    public List<Id> graxDataRecIds2ProcessForChild;
    public Boolean isArchive;
    
    public GRAXBatchToProcessSchedJob(String jobId, List<GRAXBackupCtrl.ObjRelStructure> objects2Process, Integer elementIndex, String selectCriteria){
        this.objects2Process = objects2Process;
        this.currentElementIndex = elementIndex;
        this.currentJobId = jobId;
        this.currentSelectCriteria = selectCriteria;
        this.parentIds2ProcessForChild = new List<Id>();
        this.graxDataRecIds2ProcessForChild = new List<Id>();
        
        if(objects2Process == null){
            // If this is the first time the batch is firing for the current Schedule Process
            // calculate the selected object hierarchy and initial query
            GRAX_Schedule_Process__c schedProcess = [SELECT Id, Selected_Object_Hierarchy_JSON__c, Select_Criteria__c, Target_Date__c, Date_Field__c, Archive__c FROM GRAX_Schedule_Process__c WHERE Id =: jobId];
            
            // Get the JSON string and convert it to the object structure
            GRAXBackupCtrl.ObjRelStructure rootSObj = (GRAXBackupCtrl.ObjRelStructure)JSON.deserialize(schedProcess.Selected_Object_Hierarchy_JSON__c, GRAXBackupCtrl.ObjRelStructure.class);
            
            // Now we have to make this structure flat, in order to process the objects one by one
            this.objects2Process = new List<GRAXBackupCtrl.ObjRelStructure>();
            this.objects2Process.add(rootSObj);
            
            Integer i = 0;
            while(this.objects2Process.size() > 0 && i < this.objects2Process.size()){
                GRAXBackupCtrl.ObjRelStructure sObjRelStruc = this.objects2Process[i];
                
                // Add all the child relationships for this SObject 
                this.objects2Process.addAll(sObjRelStruc.childObjRelStructure);
                
                i++;
            }
            
            // Define the rest of the main variables
            this.currentObjRelStrucUniqueKey = rootSObj.uniqueKey;
            this.currentElementIndex = 0;
            this.isArchive = schedProcess.Archive__c;
            
            String rootObjSelectCriteria = '';
            this.currentSelectCriteria = '';
            
            String objName = this.objects2Process[this.currentElementIndex].name;
            
            // Set up the date / datetime in the filter criteria
            String dateFieldType = getFieldType(objName, schedProcess.Date_Field__c);
            String dateFieldValue = String.valueOf(schedProcess.Target_Date__c);
            
            if(dateFieldType.equalsIgnoreCase('Datetime')){
                dateFieldValue += 'T00:00:00.000Z';
            }
            
            if(schedProcess.Select_Criteria__c == 'Main Object not modified'){
                rootObjSelectCriteria = schedProcess.Date_Field__c + ' <= ' + dateFieldValue;
            }
            //else if(schedProcess.Select_Criteria__c == 'Main Object and Children not modified'){
            //    this.currentSelectCriteria = 'LastModifiedDate <= ' + schedProcess.Selected_Time_Frame__c;
            //}
                        
            query = 'SELECT ' + getSObjectFields(objName);
            query += ' FROM ' + objName;
            if(rootObjSelectCriteria <> ''){
                query += ' WHERE ' + rootObjSelectCriteria;
            }
        }else{
            // Get the current child object structure
            GRAXBackupCtrl.ObjRelStructure sObjRelStruc = this.objects2Process[this.currentElementIndex];
            
            this.currentObjRelStrucUniqueKey = sObjRelStruc.uniqueKey;
            
            // Get the parent record Ids that still haven't been processed 
            for(GRAX_Data_Record_Id__c grxDRId : [SELECT Id, SFDC_Id__c FROM GRAX_Data_Record_Id__c WHERE (Processed_Child_Index__c = null OR Processed_Child_Index__c <: this.currentElementIndex) AND GRAX_Data_Record__r.GRAX_Schedule_Process__c =: this.currentJobId AND GRAX_Data_Record__r.Sched_Proc_Hierarchy_Unique_Key__c =: sObjRelStruc.parentUniqueKey LIMIT :maxParentIds2ProcessByChildIteration]){
                this.parentIds2ProcessForChild.add(grxDRId.SFDC_Id__c);
                this.graxDataRecIds2ProcessForChild.add(grxDRId.Id);
            }
            
            String objName = sObjRelStruc.name;
            
            query = 'SELECT ' + getSObjectFields(objName);
            query += ' FROM ' + objName;
            query += ' WHERE ' + sObjRelStruc.relatedFieldName + ' IN :parentIds2ProcessForChild';
            
            if(this.currentSelectCriteria <> ''){
                query += ' AND ' + this.currentSelectCriteria;
            }
        }
        
        System.debug('Ari1: ' + query);
    }
    
    global Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        // Generate the JSON Content for these records
        String content = GRAXApi.jsonContentArchive(scope);
        
        // Get the SObject Name and the list of Ids being processed 
        String sobjectName = this.objects2Process[this.currentElementIndex].name;
        String sfdcIds = '';

        for(SObject sObj : scope){
            sfdcIds += ';' + sObj.Id;
        }
        sfdcIds = sfdcIds.substring(1);
        
        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
        dr.Salesforce_ID__c = sfdcIds;
        dr.Salesforce_Object__c = sobjectName;
        dr.Status__c = 'Not Sent';
        dr.of_Times_Sent__c = 0;
        dr.Error_Message__c = null;
        dr.GRAX_Schedule_Process__c = this.currentJobId;
        dr.Sched_Proc_Hierarchy_Unique_Key__c = this.currentObjRelStrucUniqueKey;
        insert dr;

        Attachment req_att = new Attachment();
        req_att.Name = 'request.txt';
        req_att.Body = Blob.valueOf(content);
        req_att.ParentId = dr.Id;
        insert req_att;
        
        // Iterate through the list of records to create a GRAX_Data_Record_Id__c instance for each one of them
        List<GRAX_Data_Record_Id__c> dataRecIds2Ins= new List<GRAX_Data_Record_Id__c>();
        for(SObject sObj : scope){
            GRAX_Data_Record_Id__c dataRecId = new GRAX_Data_Record_Id__c();
            dataRecId.SFDC_Id__c = sObj.Id;
            dataRecId.GRAX_Data_Record__c = dr.Id;
            if(this.isArchive){
                dataRecId.Status__c = 'To be Deleted';
            }
            dataRecIds2Ins.add(dataRecId);
        }
        
        insert dataRecIds2Ins;
    }
    
    global void finish(Database.BatchableContext BC){
        Boolean continue2NextChildObject = true;
        
        // Check if this is a Child object being evaluated
        if(this.currentElementIndex > 0){
            List<GRAX_Data_Record_Id__c> graxDataRecs2Up = new List<GRAX_Data_Record_Id__c>();
            
            // Flag all the parent Ids that have been processed during this execution
            for(Id graxDataRecId : this.graxDataRecIds2ProcessForChild){
                GRAX_Data_Record_Id__c grxDRId2Up = new GRAX_Data_Record_Id__c(Id = graxDataRecId);
                grxDRId2Up.Processed_Child_Index__c = this.currentElementIndex;
                graxDataRecs2Up.add(grxDRId2Up);
            }
            
            if(graxDataRecs2Up.size() > 0){
                update graxDataRecs2Up;
            }
            
            // Get the current child object structure
            GRAXBackupCtrl.ObjRelStructure sObjRelStruc = this.objects2Process[this.currentElementIndex];
            
            // Verify that there is at least one more parent record Id that still hasn't been processed 
            for(GRAX_Data_Record_Id__c grxDRId : [SELECT Id, SFDC_Id__c FROM GRAX_Data_Record_Id__c WHERE (Processed_Child_Index__c = null OR Processed_Child_Index__c <: this.currentElementIndex) AND GRAX_Data_Record__r.GRAX_Schedule_Process__c =: this.currentJobId AND GRAX_Data_Record__r.Sched_Proc_Hierarchy_Unique_Key__c =: sObjRelStruc.parentUniqueKey LIMIT 1]){
                continue2NextChildObject = false;
            }
        }
        
        // Increase the object index and continue with the next child object in the hierarchy list, when:
        // - The root object has completed processing
        // - There are no more parent record Ids to process
        if(continue2NextChildObject){
            this.currentElementIndex = this.currentElementIndex + 1;
        }
        
        if(this.currentElementIndex < this.objects2Process.size()){
            // Now we have to call the batch again based on the current parameters
            GRAXBatchToProcessSchedJob b = new GRAXBatchToProcessSchedJob(this.currentJobId, this.objects2Process, this.currentElementIndex, this.currentSelectCriteria);
            
            if(!Test.isRunningTest()){
                database.executebatch(b, 1000);
            }
        }else{
            // Update the Last Run Date and Next Run Date on the current Schedule Process record
            GRAX_Schedule_Process__c schedProcess = [SELECT Id, Schedule_Type__c, Next_Run_Date__c FROM GRAX_Schedule_Process__c WHERE Id =: this.currentJobId];
            schedProcess.Next_Run_Date__c = getNextRunDate(schedProcess.Next_Run_Date__c, schedProcess.Schedule_Type__c);
            schedProcess.Last_Run_Date__c = System.now();
            schedProcess.Status__c = 'Completed';
            update schedProcess;
        }
    }
    
    private String getSObjectFields(String objName){
        // Get a map of field name and field token
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fMap = globalDescribe.get(objName).getDescribe().Fields.getMap();
        String selectFields = '';
        
        if(fMap != null){
            for(Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields += ',' + fd.getName();
            }
            selectFields = selectFields.substring(1);
        }
        
        return selectFields;
    }
    
    private String getFieldType(String objName, String fieldName){
        String result = 'Date';
        
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fMap = globalDescribe.get(objName).getDescribe().Fields.getMap();
        
        if(fMap.containsKey(fieldName)){
            Schema.DescribeFieldResult fd = fMap.get(fieldName).getDescribe();
            result = fd.getType().name();
        }
        
        return result;
    }
    
    private Datetime getNextRunDate(Datetime previousRunDate, String frequency){
        Datetime result = null; // This is the default value returned in case the frequency is set to "Once"
        
        // Calculate the Next Run Date based on the selected frequency 
        if(frequency == 'Daily'){
            result = previousRunDate.addDays(1);
        }else if(frequency == 'Weekly'){
            result = previousRunDate.addDays(7);
        }else if(frequency == 'Monthly'){
            result = previousRunDate.addMonths(1);
        }else if(frequency == 'Quarterly'){
            result = previousRunDate.addMonths(3);
        }else if(frequency == 'Semi-Annually'){
            result = previousRunDate.addMonths(6);
        }else if(frequency == 'Annually'){
            result = previousRunDate.addYears(1);
        }
        
        return result;
    }
}