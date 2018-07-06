/*****************************************************************************************
Name              : GRAXBatchToProcessSchedJobFromReport
Description       : 
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Leandro Brunner      06/14/2018
******************************************************************************************/
global with sharing class GRAXBatchToProcessSchedJobFromReport implements Database.batchable<Id>, Database.Stateful, Database.AllowsCallouts {
    private String query;
    private GRAXCSVIterator csvIt;
    private Integer splitSize = 100;
    public String currentArchiveProcessId;
    public String currentObjRelStrucUniqueKey;
    
    private GRAX_Schedule_Process__c schedProcess;
    private Boolean isArchive = false;
    private List<Id> idList = new List<Id>();
    public Boolean isExecuteNow = false;

    public GRAXBatchToProcessSchedJobFromReport(String jobId, GRAX_Schedule_Process__c schedProcess, GRAXCSVIterator csvIt, Integer splitSize) {
        this(jobId, schedProcess, csvIt, splitSize, null);
    }

    public GRAXBatchToProcessSchedJobFromReport(String jobId, GRAX_Schedule_Process__c schedProcess, GRAXCSVIterator csvIt, Integer splitSize, String csvTest) {
        if(schedProcess <> null && csvIt <> null) {
            this.schedProcess = schedProcess;
            this.csvIt = csvIt;
        } else {
            this.schedProcess = [SELECT Id, Selected_Object_Hierarchy_JSON__c, Select_Criteria__c, Target_Report__c, Object_Name__c, Archive__c FROM GRAX_Schedule_Process__c WHERE Id =: jobId];

            if(this.schedProcess.Archive__c){
                GRAX_Archive_Process__c archiveProc = new GRAX_Archive_Process__c();
                archiveProc.GRAX_Schedule_Process__c = this.schedProcess.Id;
                archiveProc.Async_Records_Successfully_Sent__c = 0;
                archiveProc.Async_Records_to_Process__c = 0;
                archiveProc.Records_Successfully_Sent__c = 0;
                archiveProc.Records_To_Process__c = 0;
                insert archiveProc;
                
                this.currentArchiveProcessId = archiveProc.Id;
                this.isArchive = true;
            }

            GRAXBackupCtrl.ObjRelStructure rootSObj = (GRAXBackupCtrl.ObjRelStructure)JSON.deserialize(this.schedProcess.Selected_Object_Hierarchy_JSON__c, GRAXBackupCtrl.ObjRelStructure.class);
        
            this.currentObjRelStrucUniqueKey = rootSObj.uniqueKey;

            List<Report> reportList = [SELECT Id FROM Report WHERE Id = :this.schedProcess.Target_Report__c];
                
            if(reportList.size() > 0 || Test.isRunningTest()) {
                String csv;

                if(Test.isRunningTest()) {
                    csv = csvTest;
                } else {
                    String reportId = (String)reportList.get(0).get('Id');

                    ApexPages.PageReference report = new ApexPages.PageReference('/' + reportId + '?csv=1&exp=1&enc=UTF-8&skipFooter=1&lexExport=1&isdtp=p1'); 

                    csv = report.getContent().toString();
                }

                this.csvIt = new GRAXCSVIterator(csv);
            }
        }

        if(splitSize <> null) {
            this.splitSize = splitSize;
        }

        this.idList.clear();

        if(csvIt <> null) {

            for (Integer i = 0; i < this.splitSize && this.csvIt.hasNext(); i++) {
                List<String> fields = this.csvIt.next();

                String sid = fields[0];

                try {
                    this.idList.add(sid);
                } catch (Exception e) {}
            }
            
        }
    }

    global Iterable<Id> start(Database.BatchableContext BC) {
        return this.idList;
    }

    global void execute(Database.BatchableContext batchableContext, List<Id> idList) {
        String objName = this.schedProcess.Object_Name__c;

        String query = 'SELECT ' + String.join(GRAXBatchToProcessSchedJob.getSObjectFields(objName), ', ');
        query += ' FROM ' + objName;
        query += ' WHERE Id IN :idList';

        List<SObject> scope = Database.query(query);

        // Generate the JSON Content for these records
        String content = GRAXApi.jsonContentArchive(scope);

        // Call the generate GRAX Data Record method for this object
        generateGRAXDataRecord(objName, this.currentObjRelStrucUniqueKey, content, scope);
    }

    global void finish(Database.BatchableContext batchableContext) {
        if(this.csvIt <> null && this.csvIt.hasNext()) {
            Database.executeBatch(new GRAXBatchToProcessSchedJobFromReport(null, this.schedProcess, this.csvIt, this.splitSize), 100);
        } else {
            GRAXBatchToProcessSchedJob b1 = new GRAXBatchToProcessSchedJob(this.schedProcess.Id, null, 0, null, this.isExecuteNow);

            if(b1.objects2Process.size() > 1) {
                GRAXBatchToProcessSchedJob b2 = new GRAXBatchToProcessSchedJob(this.schedProcess.Id, b1.objects2Process, 1, b1.currentSelectCriteria, b1.isExecuteNow);
                b2.isArchive = b1.isArchive;
                b2.currentArchiveProcessId = this.currentArchiveProcessId;
                b2.isExecuteNow = b1.isExecuteNow;
                b2.hasContentDocument = b1.hasContentDocument;

                database.executebatch(b2, GRAXUtils.getBatchMaxExecutionNumber());
            } else if(this.isExecuteNow) {
                GRAXBatchToResendDataRecords batchToResendDataRecords = new GRAXBatchToResendDataRecords();
                batchToResendDataRecords.currentJobId = b1.currentJobId;
                batchToResendDataRecords.isExecuteNow = b1.isExecuteNow;
                batchToResendDataRecords.isArchive = b1.isArchive;

                database.executebatch(batchToResendDataRecords, 10);
            } else {
                this.schedProcess.Last_Run_Date__c = System.now();
                this.schedProcess.Status__c = 'Completed';
                update this.schedProcess;
            }
        }
    }

    public void generateGRAXDataRecord(String sobjectName, String objRelStrucUniqueKey, String jsonContent, List<SObject> sObjRecs){
        String sfdcIds = '';

        for(SObject sObj : sObjRecs){
            sfdcIds += ';' + sObj.Id;
        }
        sfdcIds = sfdcIds.substring(1);
        
        GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
        dr.Salesforce_ID__c = sfdcIds;
        dr.Salesforce_Object__c = sobjectName;
        dr.Status__c = 'Not Sent';
        dr.of_Times_Sent__c = 0;
        dr.Error_Message__c = null;
        dr.GRAX_Schedule_Process__c = this.schedProcess.Id;
        dr.Sched_Proc_Hierarchy_Unique_Key__c = objRelStrucUniqueKey;
        dr.GRAX_Archive_Process__c = this.currentArchiveProcessId;
        insert dr;

        String dataRecIdStatus;
        if(this.isArchive){
            dataRecIdStatus = 'To be Deleted';
        }
        
        // Iterate through the list of records to create a GRAX_Data_Record_Id__c instance for each one of them
        Map<Id, GRAX_Data_Record_Id__c> dataRecIds2InsBySObjId = new Map<Id, GRAX_Data_Record_Id__c>();
        for(SObject sObj : sObjRecs){
            GRAX_Data_Record_Id__c dataRecId = new GRAX_Data_Record_Id__c();
            dataRecId.SFDC_Id__c = sObj.Id;
            dataRecId.GRAX_Data_Record__c = dr.Id;
            dataRecId.Status__c = dataRecIdStatus;
            
            dataRecIds2InsBySObjId.put(sObj.Id, dataRecId);
        }
        
        insert dataRecIds2InsBySObjId.values();
        
        // Save the Attachment with the JSON content associated to the GRAX_Data_Record__c
        Attachment req_att = new Attachment();
        req_att.Name = 'request.txt';
        req_att.Body = Blob.valueOf(jsonContent);
        req_att.ParentId = dr.Id;
        insert req_att;
    }
}