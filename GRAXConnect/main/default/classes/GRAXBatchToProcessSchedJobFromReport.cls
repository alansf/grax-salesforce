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
    
    private GRAX_Schedule_Process__c schedProcess;
    private List<Id> idList = new List<Id>();
    public Boolean isExecuteNow = false;
    
    public GRAXBatchToProcessSchedJob mainBatchProcess;

    public GRAXBatchToProcessSchedJobFromReport(String jobId, GRAXCSVIterator csvIt, Integer splitSize) {
        if(csvIt <> null) {
            this.csvIt = csvIt;
        } else {
            schedProcess = [SELECT Id, Target_Report__c, Object_Name__c FROM GRAX_Schedule_Process__c WHERE Id =: jobId];
            
            // Retrieve the selected Report from the Database to validate that it is still valid
            List<Report> reportList = [SELECT Id FROM Report WHERE Id = :schedProcess.Target_Report__c];
                
            if(reportList.size() > 0 || Test.isRunningTest()) {
                String csv;

                if(Test.isRunningTest()) {
                    csv = GRAXBatchToProcessSchedJobFromReportTest.csvTest;
                } else {
                    String reportId = (String)reportList.get(0).get('Id');
                    
                    // Use the standard download page of the Report to get the CSV file with all the records 
                    ApexPages.PageReference report = new ApexPages.PageReference('/' + reportId + '?csv=1&exp=1&enc=UTF-8&skipFooter=1&lexExport=1&isdtp=p1'); 

                    csv = report.getContent().toString();
                }

                this.csvIt = new GRAXCSVIterator(csv);
            }
            
            this.mainBatchProcess = new GRAXBatchToProcessSchedJob(jobId, null, 0, null, isExecuteNow, false);
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
        mainBatchProcess.query += ' WHERE Id IN :idList';
        
        List<SObject> scope = Database.query(mainBatchProcess.query);

        // Call the generate GRAX Data Record method for this object
        this.mainBatchProcess.executeMethod(scope);
    }

    global void finish(Database.BatchableContext batchableContext) {
        if(this.csvIt <> null && this.csvIt.hasNext()) {
            GRAXBatchToProcessSchedJobFromReport b = new GRAXBatchToProcessSchedJobFromReport(null, this.csvIt, this.splitSize);
            b.mainBatchProcess = this.mainBatchProcess;
            Database.executeBatch(b, GRAXUtils.getBatchMaxExecutionNumber(schedProcess.Object_Name__c));
        } else {
            this.mainBatchProcess.finishMethod();
        }
    }
}