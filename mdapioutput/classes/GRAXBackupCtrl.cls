/*****************************************************************************************
Name              : GRAXBackupCtrl
Description       : Implementation of the tab "Back Up" in GRAXSetupUI.
Revision History  :
Created/Modified by   Created/Modified Date     Requested by        Related Task/Issue     
----------------------------------------------------------------------------------------
1. Leandro Brunner         04/27/2018             David Mackey        GRAX Audit Trail Process (https://app.asana.com/0/326600806074978/633149554508926/f)
2. Ariel Yankelevich       07/18/2018             David Mackey        Multi-Object Backup (https://app.asana.com/0/326600806074978/743044564916005/f)
******************************************************************************************/
public with sharing class GRAXBackupCtrl {
    public String userTimeZone {get;set;}
    public String selectedObject {get;set;}
    public String selectedObjectDefault {get;set;}
    public String sObjectDateField {get;set;}
    public String sObjectDateFieldDefault {get;set;}

    private Set<String> excludedStandardObjects = new Set<String>{'AccountCleanInfo','ContentDistribution','DuplicateRecordItem','EntitySubscription','ProcessInstance','TopicAssignment','AccountPartner','ContactCleanInfo','EmailMessageRelation','EventRelation','OpportunityPartner','Partner','CollaborationGroupRecord','CaseTeamMember','CaseTeamTemplateRecord','FlowRecordRelation','NetworkUserHistoryRecent','UserFieldAccess','UserEntityAccess'};
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

    public Attachment selectionAttachment {get;set;}

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
    public Map<Id, ScheduledProcess> multiObjectBackupMap {get;set;}

    public String scheduledProcessType {get;set;}

    public GRAXBackupCtrl() {
        userTimeZone = UserInfo.getTimeZone().getID();
        selectedObject = '';
        targetReport = '';
        sObjectDateFieldDefault = 'LastModifiedDate';
        criteria = 'Main Object not modified';
        filterCriteriaType = 'Date';
        archive = false;
        gsp = new GRAX_Schedule_Process__c();
        scheduledProcessMap = new Map<Id, ScheduledProcess>();
        multiObjectBackupMap = new Map<Id, ScheduledProcess>();

        scheduledProcessType = '';

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

        public ObjRelStructure() {}
    }

    private void addAllChildRelationships(ObjRelStructure sObjRelStruc, List<ObjRelStructure> allObjRelStructure, Set<String> childsToBeVisitedUniqueKey){
        // Get the object description
        if(GRAXUtils.sObjectExists(sObjRelStruc.name)){
            Schema.DescribeSObjectResult sObjDesc = GRAXUtils.getObjectDescribe(sObjRelStruc.name);
            
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

            Schema.DescribeSObjectResult rootSObjDesc = GRAXUtils.getObjectDescribe(selectedObject);

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
        Boolean condition = false;

        if(scheduledProcessType == 'Multi-Object') {
            condition = objectJSON <> null;
            condition = condition && schedule <> null;
            condition = condition && scheduleStartDate <> null;
            condition = condition && scheduleStartTime <> null;
            condition = condition && objectJSON <> '[]';

            if(condition) {
                gsp.Select_Criteria__c = criteria;

                List<ObjRelStructure> selection = (List<ObjRelStructure>)JSON.deserialize(objectJSON, List<ObjRelStructure>.class);
                if(selection.size() > 0) {
                    gsp.Object_Name__c = selection.get(0).uniqueKey;
                }
            }
        }
        
        if(scheduledProcessType == 'Hierarchy') {
            condition = selectedObject <> null;
            condition = condition && sObjectDateField <> null;
            condition = condition && (targetDate <> null || targetReport <> null);
            condition = condition && (filterCriteriaType == 'Date' || filterCriteriaType == 'Report');
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
                    gsp.Select_Criteria__c = criteria;
                    gsp.Target_Report__c = null;
                }
                if(filterCriteriaType == 'Report') {
                    gsp.Target_Report__c = targetReport;
                    gsp.Select_Criteria__c = null;
                    gsp.Target_Date__c = null;
                }
                gsp.Archive__c = archive;
            }
        }

        if(condition) {
            gsp.type__c = scheduledProcessType;
            gsp.Schedule_Type__c = schedule;
            gsp.Schedule_Start_Date__c = createDate(scheduleStartDate);
            gsp.Schedule_Start_Time__c = scheduleStartTime;
            gsp.Next_Run_Date__c = createDateTime(scheduleStartDate, scheduleStartTime);

            // Insert or update the record.
            upsert gsp;

            if(selectionAttachment <> null) {
                GRAXUtils.setSelectionJSON(selectionAttachment, objectJSON);
            } else {
                GRAXUtils.setSelectionJSON(gsp.Id, objectJSON);
            }


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
        scheduledProcessType = '';
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
        selectionAttachment = null;
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
        
        Boolean scheduleProcessExist = scheduledProcessMap.containsKey(spId);
        Boolean multiObjectExist = multiObjectBackupMap.containsKey(spId);

        // Check if the Scheduled Process exist.
        if(scheduleProcessExist || multiObjectExist) {
            // Set the selection.
            if(scheduleProcessExist) {
                gsp = scheduledProcessMap.get(spId).GRAXScheduleProcess;
            }

            if(multiObjectExist) {
                gsp = multiObjectBackupMap.get(spId).GRAXScheduleProcess;
            }

            scheduledProcessType = gsp.type__c;
            selectedObject = gsp.Object_Name__c;
            sObjectDateField = gsp.Date_Field__c;
            targetDate = String.valueOf(gsp.Target_Date__c);
            targetReport = gsp.Target_Report__c;
            criteria = gsp.Select_Criteria__c;
            if(targetDate <> null) {
                filterCriteriaType = 'Date';
            }
            if(targetReport <> null) {
                filterCriteriaType = 'Report';
                criteria = 'Main Object not modified';
            }
            schedule = gsp.Schedule_Type__c;
            scheduleStartDate = gsp.Schedule_Start_Date__c.format();
            scheduleStartTime = gsp.Schedule_Start_Time__c;

            //objectJSON = gsp.Selected_Object_Hierarchy_JSON__c;
            selectionAttachment = GRAXUtils.getSelectionAttachment(gsp.Id);
            objectJSON = GRAXUtils.getSelectionJSON(selectionAttachment);

            archive = gsp.Archive__c;
        }

        return null;
    }

    // Delete a ScheduledProcess.
    public Pagereference deleteScheduledProcess() {
        // Get Id of the Scheduled Process to delete.
        Id spId = Apexpages.currentPage().getParameters().get('spId');

        Boolean scheduleProcessExist = scheduledProcessMap.containsKey(spId);
        Boolean multiObjectExist = multiObjectBackupMap.containsKey(spId);

        // Check if the Scheduled Process exist.
        if(scheduleProcessExist || multiObjectExist) {
            ScheduledProcess sp;

            if(scheduleProcessExist) {
                sp = scheduledProcessMap.get(spId);

                scheduledProcessMap.remove(spId);
            }

            if(multiObjectExist) {
                sp = multiObjectBackupMap.get(spId);

                multiObjectBackupMap.remove(spId);
            }

            delete sp.GRAXScheduleProcess;
        }

        return null;
    }
    

    // Update scheduledProcessMap with the latest data.
    public void updateScheduledProcessMap() {
        // Get the Map of GRAX_Schedule_Process__c
        Map<ID, GRAX_Schedule_Process__c> GRAXScheduledProcessMap = new Map<ID, GRAX_Schedule_Process__c>([SELECT Id, type__c, Select_Criteria__c, Object_Name__c, Target_Date__c, Target_Report__c, Schedule_Start_Date__c, Schedule_Start_Time__c, Last_Run_Date__c, Next_Run_Date__c, Date_Field__c, Schedule_Type__c, Archive__c, CreatedDate, CreatedBy.Name FROM GRAX_Schedule_Process__c WHERE isDeleted = false ORDER BY Object_Name__c, Last_Run_Date__c]);

        scheduledProcessMap.clear();

        if(GRAXScheduledProcessMap.size() > 0) {
            // Walk the filtered list of CronTriggers.
            for(GRAX_Schedule_Process__c gsp : GRAXScheduledProcessMap.values()) {
                ScheduledProcess sp = new ScheduledProcess();

                sp.createdBy = gsp.CreatedBy.Name;
                sp.createdDate = gsp.CreatedDate.format('MM/dd/yyyy', userTimeZone);
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
                if(gsp.type__c == 'Hierarchy') {
                    scheduledProcessMap.put(gsp.Id, sp);
                }

                if(gsp.type__c == 'Multi-Object') {
                    multiObjectBackupMap.put(gsp.Id, sp);
                }
            }
        }
    }

    public Pagereference execScheduledProcess() {
        // Get Id of the Scheduled Process to execute.
        Id spId = Apexpages.currentPage().getParameters().get('spId');
        

        Boolean scheduleProcessExist = scheduledProcessMap.containsKey(spId);
        Boolean multiObjectExist = multiObjectBackupMap.containsKey(spId);

        // Check if the Scheduled Process exist.
        if(scheduleProcessExist || multiObjectExist) {
            GRAX_Schedule_Process__c gsp;

            if(scheduleProcessExist) {
                gsp = scheduledProcessMap.get(spId).GRAXScheduleProcess;
            }

            if(multiObjectExist) {
                gsp = multiObjectBackupMap.get(spId).GRAXScheduleProcess;
            }

            try{
                if(gsp.Target_Date__c <> null || multiObjectExist) {
                    Database.executebatch(new GRAXBatchToProcessSchedJobMainObject(gsp.Id, true, multiObjectExist), GRAXUtils.getBatchMaxExecutionNumber(gsp.Object_Name__c));
                }

                if(gsp.Target_Report__c <> null) {
                    GRAXBatchToProcessSchedJobFromReport b = new GRAXBatchToProcessSchedJobFromReport(gsp.Id, null, 100, true);
                    
                    Database.executeBatch(b, GRAXUtils.getBatchMaxExecutionNumber(gsp.Object_Name__c));
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

    public List<ScheduledProcess> getMultiObjectBackup() {
        return multiObjectBackupMap.values();
    }
    
    public List<SelectOption> getSObjectDateFields(){
        List<SelectOption> options = new List<SelectOption>();

        if(String.isNotBlank(selectedObject)) {
            Set<String> dateTypes = new Set<String>{'date','datetime'};
            
            for(Schema.DescribeFieldResult fd : GRAXUtils.getDescribeFieldsResultForObject(selectedObject).values()) {
                if(dateTypes.contains(fd.getType().name().toLowerCase())){
                    options.add(new SelectOption(fd.getName(), fd.getLabel()));
                }
            }
        }
        
        return options;
    }

    public String getReportsJSON() {
        List<Object> rList = new List<Object>();
        Map<String, Object> rMap;

        for (Report r : [SELECT Id, Name FROM Report WHERE Format = 'Tabular' AND (FolderName Like '%GRAX%' OR Name Like '%GRAX%') ORDER BY CreatedDate DESC]) {
            rMap = new Map<String, Object>();
            rMap.put('id', r.Id);
            rMap.put('name', r.Name);

            rList.add(rMap);
        }
        
        return JSON.serialize(rList);
    }

    public String getItemsJSON() {
        List<ObjRelStructure> objs = new List<ObjRelStructure>();
        ObjRelStructure obj;

        for(SelectOption op : getItems()) {
            if(!op.getDisabled()) {
                obj = new ObjRelStructure();
                obj.uniqueKey = op.getValue();
                obj.name = op.getLabel();

                objs.add(obj);
            }
        }

        return JSON.serialize(objs);
    }

}