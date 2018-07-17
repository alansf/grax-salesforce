<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>GRAX</application>
        <default>false</default>
        <visible>true</visible>
    </applicationVisibilities>
    <applicationVisibilities>
        <application>GRAX_Classic</application>
        <default>false</default>
        <visible>true</visible>
    </applicationVisibilities>

    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>GRAXQuery__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>GRAX_Data_Record_Id__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>GRAX_Data_Record__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>GRAX_Schedule_Process__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>

    <classAccesses>
        <apexClass>GRAXAccountReportingCtrl</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXApi</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXApiUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXArchiveProcessTriggerHandler</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXAuditTrail</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBackupCtrl</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBackupCtrlTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatch</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToCleanDataRecords</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToCleanDataRecordsTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToDeleteBackedUpData</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToDeleteBackedUpDataTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToProcessSchedJob</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToProcessSchedJobFromReport</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToProcessSchedJobFromReportTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToProcessSchedJobMainObject</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToProcessSchedJobTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToResendDataRecords</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchToResendDataRecordsTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXBatchUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXCSVIterator</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXCSVIteratorTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXCloud</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXCloudUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXConfiguration</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXConfigurationUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXConnect</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXConnectUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXDataRecordTriggerHandler</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXDataRecordTriggerTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXDeploy</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXDeployUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXException</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXExceptionUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXFlow</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXFlowUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXLogRecord</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXLogging</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXRestoreCtrl</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXRestoreCtrlTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSchedulerToCleanDataRecords</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSchedulerToCleanDataRecordsTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSchedulerToDeleteBackedUpData</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSchedulerToDeleteBackedUpDataTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSchedulerToProcessSchedJobs</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSchedulerToProcessSchedJobsTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSchedulerToResendDataRecords</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSchedulerToResendDataRecordsTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSettings</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSettingsUT</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSetupCtrl</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSetupCtrlTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXSupportCtrl</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXTimeMachineCtrl</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXTimeMachineCtrlTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXUnitTest</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GRAXUtils</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <custom>false</custom>

    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.Do_Not_Store_Data__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.Enable_Audit_Log__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.Filter__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.GRAX_Configured__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.Hourly_Synch_Period__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>GRAXQuery__c.Last_Synch__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.Order_By__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.Selected_Fields__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.Total_Records_Processed__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAXQuery__c.graxconfig__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record_Id__c.Error_Description__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record_Id__c.Processed_Child_Index__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record_Id__c.SFDC_Id__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record_Id__c.Status__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.Error_Message__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.GRAX_Archive_Process__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.GRAX_Schedule_Process__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.Last_Sent_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>GRAX_Data_Record__c.Records_Sent_to_GRAX__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>GRAX_Data_Record__c.Records_To_Process__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.Salesforce_ID__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.Salesforce_Object__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.Sched_Proc_Hierarchy_Unique_Key__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.Status__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Data_Record__c.of_Times_Sent__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Archive__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Date_Field__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Last_Run_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Next_Run_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Object_Name__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Schedule_Start_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Schedule_Start_Time__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Schedule_Type__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Select_Criteria__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Status__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Target_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.Target_Report__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Schedule_Process__c.type__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Account_Reporting_Setting__mdt.Filter_Key_Id__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Account_Reporting_Setting__mdt.Filter_Key__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Account_Reporting_Setting__mdt.Report_ID__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Account_Reporting_Setting__mdt.cacheResults__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Account_Reporting_Setting__mdt.filterKeyIndex__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>GRAX_Account_Reporting_Setting__mdt.size__c</field>
        <readable>true</readable>
    </fieldPermissions>

    <layoutAssignments>
        <layout>GRAXQuery__c-GRAXQueries Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>GRAX_Data_Record__c-GRAX Data Record Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>GRAX_Schedule_Process__c-GRAX Schedule Process Layout</layout>
    </layoutAssignments>

    <pageAccesses>
        <apexPage>GRAXAbout</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXBackup</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXConfiguration</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXConnect</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXDeploy</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXFlow</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXRestore</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXSetup</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXSupport</apexPage>
        <enabled>true</enabled>
    </pageAccesses>
    <pageAccesses>
        <apexPage>GRAXAccountReporting</apexPage>
        <enabled>true</enabled>
    </pageAccesses>

    <tabVisibilities>
        <tab>GRAX_Intro</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
    <tabVisibilities>
        <tab>GRAX_DEPLOY</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
    <tabVisibilities>
        <tab>GRAX_Support</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
    <tabVisibilities>
        <tab>GRAXQuery__c</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
</Profile>
