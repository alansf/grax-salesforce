/*****************************************************************************************
Name              : GRAXBackupCtrl
Description       : Implementation of the tab "Back Up" in GRAXSetupUI.
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner       04/27/2018             David Mackey        GRAX Audit Trail Process (https://app.asana.com/0/326600806074978/633149554508926/f)
******************************************************************************************/
public with sharing class GRAXBackupCtrl {
    public String userTimeZone {get;set;}
    public String selectedObject {get;set;}
    public String selectedObjectDefault {get;set;}
    public String sObjectDateField {get;set;}
    public String sObjectDateFieldDefault {get;set;}

    public Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    private Set<String> excludedStandardObjects = new Set<String>{'AccountCleanInfo','ContentDistribution','DuplicateRecordItem','EntitySubscription','ProcessInstance','TopicAssignment','AccountPartner','ContactCleanInfo','EmailMessageRelation','EventRelation','OpportunityPartner','Partner','CollaborationGroupRecord','CaseTeamMember','CaseTeamTemplateRecord','FlowRecordRelation','NetworkUserHistoryRecent'};
    private Set<String> excludedStandardObjectSufixes = new Set<String>{'Share','History','Feed'};

    public String filterCriteriaType {get;set;}
    public String targetDate {get;set;}
    public String targetReport {get;set;}
    public String criteria {get;set;}
    public String schedule {get;set;}
    public String scheduleStartDate {get;set;}
    public String scheduleStartTime {get;set;}
    public String objectJSON {get;set;}
    public Boolean archive {get;set;}

    public class ScheduledProcess {
        public Id cronId {get;set;}
        public String createdBy {get;set;}
        public String createdDate {get;set;}
        public String lastRunDate {get;set;}
        public String nextRunDate {get;set;}
        public String parentObject {get;set;}
        public String archive {get;set;}
        public GRAX_Schedule_Process__c GRAXScheduleProcess {get;set;}
    }

    public GRAX_Schedule_Process__c gsp {get;set;}
    public Map<Id, ScheduledProcess> scheduledProcessMap {get;set;}

    public GRAXBackupCtrl() {
        userTimeZone = UserInfo.getTimeZone().getID();
        selectedObject = '';
        targetReport = '';
        sObjectDateFieldDefault = 'LastModifiedDate';
        criteria = 'Main Object not modified';
        archive = false;
        gsp = new GRAX_Schedule_Process__c();
        scheduledProcessMap = new Map<Id, ScheduledProcess>();

        updateScheduledProcessMap();
    }

    public List<SelectOption> getItems() 
    {   
        String objectname;
        List<SelectOption> options = new List<SelectOption>();
        Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();
            options.add(new SelectOption('' ,'-- SELECT SALESFORCE OBJECT --', true));
        for (String apiName : sObjects.keySet())
        {
            Map<String, Schema.RecordTypeInfo> types = sObjects.get(apiName).getDescribe().getRecordTypeInfosByName();
            if (types.size() > 0){
                objectname = sObjects.get(apiName).getDescribe().getName();
                options.add(new SelectOption(objectname ,objectname ));
            }
        }
        options.sort();
        
        return options;
    }

    public Pagereference changeSelectedObject() {
        selectedObject = Apexpages.currentPage().getParameters().get('selectedObjectValue');
        sObjectDateField = sObjectDateFieldDefault;

        return null;
    }
    
    // This structure is used to encapsulate the object relationship structure
    public class ObjRelStructure {
        public String uniqueKey {get; set;}
        public String name {get; set;}
        public String label {get; set;}
        public String parentUniqueKey {get; set;}
        public String relationshipName {get; set;}
        public String relatedFieldName {get; set;}
        public Boolean isCascadeDelete {get; set;}
        public List<ObjRelStructure> childObjRelStructure {get; set;}
        
        public ObjRelStructure(Schema.DescribeSObjectResult objDesc, Schema.ChildRelationship childRel){
            this.name = objDesc.getName();
            this.label = objDesc.getLabel();
            if(childRel <> null){
                this.relationshipName = childRel.getRelationshipName();
                this.isCascadeDelete = childRel.isCascadeDelete();
                this.relatedFieldName = String.valueOf(childRel.getField());
            }
            
            childObjRelStructure = new List<ObjRelStructure>();
        }
    }

    private void addAllChildRelationships(ObjRelStructure sObjRelStruc, List<ObjRelStructure> allObjRelStructure, Set<String> childsToBeVisitedUniqueKey){
        // Get the object description
        if(globalDescribe.containsKey(sObjRelStruc.name)){
            Schema.DescribeSObjectResult sObjDesc = globalDescribe.get(sObjRelStruc.name).getDescribe();
            
            if(sObjDesc.getChildRelationships().size() > 0){
                //Visit all the Child Relationships of this SObject
                for(Schema.ChildRelationship childRel : sObjDesc.getChildRelationships()){
                    String uniqueKey = sObjRelStruc.name + '_' + childRel.getRelationshipName();
                    
                    if(!childsToBeVisitedUniqueKey.contains(uniqueKey)){
                        childsToBeVisitedUniqueKey.add(uniqueKey);
                        
                        Schema.DescribeSObjectResult childSObjDesc = childRel.getChildSObject().getDescribe();
                        String objName = childSObjDesc.getName();
                        
                        // Verify that this Child Object is accessible, queryeable, etc
                        if(!excludedStandardObjects.contains(objName) && childSObjDesc.isAccessible() && childSObjDesc.isQueryable()){
                            // Check that this object name does not end with any of the excluded sufixes
                            Boolean endsWithExcludedStdSuffix = false;
                            for(String stdObjSuffix : excludedStandardObjectSufixes){
                                if(objName.endsWith(stdObjSuffix)){
                                    endsWithExcludedStdSuffix = true;
                                    break;
                                }
                            }
                            
                            if(!endsWithExcludedStdSuffix){
                                ObjRelStructure childSObjRelStruc = new ObjRelStructure(childSObjDesc, childRel);
                                childSObjRelStruc.uniqueKey = uniqueKey;
                                childSObjRelStruc.parentUniqueKey = sObjRelStruc.uniqueKey;
                                
                                // Add this Child SObject to the current SObject related Childs
                                sObjRelStruc.childObjRelStructure.add(childSObjRelStruc);
                                
                                // Also add it to the Flat structure in order to process it in a future iteration
                                allObjRelStructure.add(childSObjRelStruc);
                            }
                        }
                    }
                }
            }
        }
    }

    public String getRelStructure() {
        if(String.isNotBlank(selectedObject)) {
            // Flat structure of nodes to be visited
            List<ObjRelStructure> allObjRelStructure = new List<ObjRelStructure>();
            Set<String> childsToBeVisitedUniqueKey = new Set<String>();

            Schema.DescribeSObjectResult rootSObjDesc = globalDescribe.get(selectedObject).getDescribe();

            // Initiate the structure on the current SObject
            ObjRelStructure rootSObj = new ObjRelStructure(rootSObjDesc, null);
            rootSObj.uniqueKey = rootSObjDesc.getName();
            rootSObj.isCascadeDelete = true;


            // Add all the child relationships for this SObject 
            addAllChildRelationships(rootSObj, allObjRelStructure, childsToBeVisitedUniqueKey);

                            
            Integer i = 0;
            Set<String> childsVisitedUniqueKey = new Set<String>();

            while(allObjRelStructure.size() > 0 && i < allObjRelStructure.size() && !childsVisitedUniqueKey.contains(allObjRelStructure[i].uniqueKey)){
                ObjRelStructure sObjRelStruc = allObjRelStructure[i];
                
                // Add all the child relationships for this SObject 
                addAllChildRelationships(sObjRelStruc, allObjRelStructure, childsToBeVisitedUniqueKey);
                
                i++;
                childsVisitedUniqueKey.add(sObjRelStruc.uniqueKey);
            }
            
            return JSON.serializePretty(rootSObj);
        } else {
            return '{}';
        }
    }

    // Create new Date intance from a date string with the format 31/12/2018
    public Date createDate(String dateStr) {
        List<String> dParts = dateStr.split('/');
        Integer y = Integer.valueOf(dParts.get(2));
        Integer m = Integer.valueOf(dParts.get(0));
        Integer d = Integer.valueOf(dParts.get(1));

        return Date.newInstance(y, m, d);
    }

    // Create new Datetime intance from a date string with the format 31/12/2018 and a time srtring with the format 23:00
    public Datetime createDateTime(String dateStr, String time24) {
        Date d = createDate(dateStr);

        List<String> timeParts =  time24.split(':');
        Integer hh = Integer.valueOf(timeParts.get(0));
        Integer mm = Integer.valueOf(timeParts.get(1));

        return DateTime.newInstance(d.year(), d.month(), d.day(), hh, mm, 0);
    }
    
    // Save the GRAX_Schedule_Process__c record based on the form data.
    public Pagereference saveScheduledProcess() {
        Boolean condition = true;
        condition = condition && selectedObject <> null;
        condition = condition && sObjectDateField <> null;
        condition = condition && (filterCriteriaType == 'Date' || targetDate <> null);
        condition = condition && (filterCriteriaType == 'Report' || targetReport <> null);
        condition = condition && criteria <> null;
        condition = condition && schedule <> null;
        condition = condition && scheduleStartDate <> null;
        condition = condition && scheduleStartTime <> null;
        condition = condition && objectJSON <> null;
        condition = condition && archive <> null;

        if(condition) {
            gsp.Object_Name__c = selectedObject;
            gsp.Date_Field__c = sObjectDateField;
            if(filterCriteriaType == 'Date') {
                gsp.Target_Date__c = createDate(targetDate);
            }
            if(filterCriteriaType == 'Report') {
                gsp.Target_Report__c = targetReport;
            }
            gsp.Select_Criteria__c = criteria;
            gsp.Schedule_Type__c = schedule;
            gsp.Schedule_Start_Date__c = createDate(scheduleStartDate);
            gsp.Schedule_Start_Time__c = scheduleStartTime;
            gsp.Next_Run_Date__c = createDateTime(scheduleStartDate, scheduleStartTime);
            gsp.Selected_Object_Hierarchy_JSON__c = objectJSON;
            gsp.Archive__c = archive;

            // Insert or update the record.
            upsert gsp;

            String graxSchedulerToProcessSchedJobs = 'GRAXSchedulerToProcessSchedJobs';
            String graxSchedulerToDeleteBackedUpData = 'GRAXSchedulerToDeleteBackedUpData';

            Set<String> crons = new Set<String>();

            for(CronTrigger ct : [
                SELECT CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name IN :new List<String>{ graxSchedulerToProcessSchedJobs, graxSchedulerToDeleteBackedUpData }
            ]) {
                crons.add(ct.CronJobDetail.Name);
            }

            // Check if the Scheduled not exist.
            if(!crons.contains(graxSchedulerToProcessSchedJobs)) {
                // RUN HOURLY
                String jobId = System.schedule(graxSchedulerToProcessSchedJobs, '0 0 * * * ?', new GRAXSchedulerToProcessSchedJobs());
            }

            // Check if the Scheduled not exist and is archive = true
            if(!crons.contains(graxSchedulerToDeleteBackedUpData) && archive) {
                // RUN HOURLY
                String jobId = System.schedule(graxSchedulerToDeleteBackedUpData, '0 0 * * * ?', new GRAXSchedulerToDeleteBackedUpData());
            }

            cleanFormData();

            // Update the Map of Scheduled Process
            updateScheduledProcessMap();
        } else {
            System.debug(LoggingLevel.Error, 'THE DATA OF THE FORM IS NOT COMPLETE');
        }

        return null;
    }

    public void cleanFormData() {
        gsp = new GRAX_Schedule_Process__c();
        selectedObject = '';
        filterCriteriaType = 'Date';
        targetDate = null;
        targetReport = '';
        criteria = 'Main Object not modified';
        schedule = null;
        scheduleStartDate = null;
        scheduleStartTime = null;
        objectJSON = null;
        archive = false;
    }

    public Pagereference cleanFormDataHandler() {
        cleanFormData();

        return null;
    }

    // Select a ScheduledProcess to edit.
    public Pagereference selectScheduledProcess() {
        cleanFormData();
        
        // Get Id of the selected Scheduled Process.
        Id spId = Apexpages.currentPage().getParameters().get('spId');

        // Check if the Scheduled Process exist.
        if(scheduledProcessMap.containsKey(spId)) {
            // Set the selection.
            gsp = scheduledProcessMap.get(spId).GRAXScheduleProcess;

            selectedObject = gsp.Object_Name__c;
            sObjectDateField = gsp.Date_Field__c;
            targetDate = String.valueOf(gsp.Target_Date__c);
            targetReport = gsp.Target_Report__c;
            if(targetDate <> null) {
                filterCriteriaType = 'Date';
            }
            if(targetReport <> null) {
                filterCriteriaType = 'Report';
            }
            criteria = gsp.Select_Criteria__c;
            schedule = gsp.Schedule_Type__c;
            scheduleStartDate = gsp.Schedule_Start_Date__c.format();
            scheduleStartTime = gsp.Schedule_Start_Time__c;
            objectJSON = gsp.Selected_Object_Hierarchy_JSON__c;
            archive = gsp.Archive__c;
        }

        return null;
    }

    // Delete a ScheduledProcess.
    public Pagereference deleteScheduledProcess() {
        // Get Id of the Scheduled Process to delete.
        Id spId = Apexpages.currentPage().getParameters().get('spId');

        // Check if the Scheduled Process exist.
        if(scheduledProcessMap.containsKey(spId)) {
            // Get ScheduledProcess
            ScheduledProcess sp = scheduledProcessMap.get(spId);
            
            // Delete GRAX_Schedule_Process__c;
            delete sp.GRAXScheduleProcess;
 
            // Remove the ScheduledProcess of the Map.
            scheduledProcessMap.remove(spId);
        }

        return null;
    }
    

    // Update scheduledProcessMap with the latest data.
    public void updateScheduledProcessMap() {
        // Get the Map of GRAX_Schedule_Process__c
        Map<ID, GRAX_Schedule_Process__c> GRAXScheduledProcessMap = new Map<ID, GRAX_Schedule_Process__c>([SELECT Id, Selected_Object_Hierarchy_JSON__c, Select_Criteria__c, Object_Name__c, Target_Date__c, Target_Report__c, Schedule_Start_Date__c, Schedule_Start_Time__c, Last_Run_Date__c, Next_Run_Date__c, Date_Field__c, Schedule_Type__c, Archive__c, CreatedDate, CreatedBy.Name FROM GRAX_Schedule_Process__c WHERE isDeleted = false ORDER BY Object_Name__c, Last_Run_Date__c]);

        scheduledProcessMap.clear();

        if(GRAXScheduledProcessMap.size() > 0) {
            // Walk the filtered list of CronTriggers.
            for(GRAX_Schedule_Process__c gsp : GRAXScheduledProcessMap.values()) {
                ScheduledProcess sp = new ScheduledProcess();

                sp.createdBy = gsp.CreatedBy.Name;
                sp.createdDate = gsp.CreatedDate.format('EEEE, MMMM d, yyyy', userTimeZone);
                if(gsp.Last_Run_Date__c <> null) {
                    sp.lastRunDate = gsp.Last_Run_Date__c.format('MM/dd/yyyy HH:mm', userTimeZone);
                }
                if(gsp.Next_Run_Date__c <> null) {
                    sp.nextRunDate = gsp.Next_Run_Date__c.format('MM/dd/yyyy HH:mm', userTimeZone);
                }
                sp.parentObject = gsp.Object_Name__c;
                sp.archive = gsp.Archive__c ? 'Yes' : 'No';
                sp.GRAXScheduleProcess = GRAXScheduledProcessMap.get(gsp.Id);

                // Add the ScheduledProcess object to the map.
                scheduledProcessMap.put(gsp.Id, sp);
            }
        }
    }

    public Pagereference execScheduledProcess() {
        // Get Id of the Scheduled Process to execute.
        Id spId = Apexpages.currentPage().getParameters().get('spId');

        // Check if the Scheduled Process exist.
        if(scheduledProcessMap.containsKey(spId)) {
            GRAX_Schedule_Process__c gsp = scheduledProcessMap.get(spId).GRAXScheduleProcess;

            try{
                if(gsp.Target_Date__c <> null) {
                    Database.executebatch(new GRAXBatchToProcessSchedJobMainObject(gsp.Id, true), 1000);
                }

                if(gsp.Target_Report__c <> null) {
                    GRAXBatchToProcessSchedJobFromReport b = new GRAXBatchToProcessSchedJobFromReport(gsp.Id, null, null, 100);
                    b.isExecuteNow = true;
                    
                    Database.executeBatch(b, 100);
                }

                gsp.Status__c = 'Running';
            } catch(System.AsyncException e){
                gsp.Status__c = 'Error';
            }

            update gsp;
        }

        return null;
    }

    // Get the list of ScheduledProcess from scheduledProcessMap, to show in a DataTable.
    public List<ScheduledProcess> getScheduledProcesses() {
        return scheduledProcessMap.values();
    }
    
    public List<SelectOption> getSObjectDateFields(){
        List<SelectOption> options = new List<SelectOption>();

        if(String.isNotBlank(selectedObject)) {
            Set<String> dateTypes = new Set<String>{'date','datetime'};
            
            // Get a map of field name and field token
            Map<String, Schema.SObjectField> fMap = globalDescribe.get(selectedObject).getDescribe().Fields.getMap();
            
            if(fMap != null){
                for(Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    if(dateTypes.contains(fd.getType().name().toLowerCase())){
                        options.add(new SelectOption(fd.getName(), fd.getLabel()));
                    }
                }
            }
        }
        
        return options;
    }

    public List<SelectOption> getReports() {   
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'-- SELECT REPORT --', true));

        for (Report r : [SELECT Id, Name FROM Report WHERE OwnerId = :UserInfo.getUserId() AND Format = 'Tabular' ORDER BY CreatedDate DESC]) {
            options.add(new SelectOption(r.Id, r.Name));
        }
        
        return options;
    }

}