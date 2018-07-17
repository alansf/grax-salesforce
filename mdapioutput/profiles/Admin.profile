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

    <userPermissions>
        <enabled>true</enabled>
        <name>ActivateContract</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ActivateOrder</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AddDirectMessageMembers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AllowUniversalSearch</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AllowViewKnowledge</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApexRestServices</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApiEnabled</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApproveContract</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AssignPermissionSets</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AssignTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AssignUserToSkill</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AuthorApex</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>BulkMacrosAllowed</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CanInsertFeedSystemFields</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CanUseNewDashboardBuilder</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CanVerifyComment</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterEditOwnPost</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterEditOwnRecordPost</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterFileLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterInternalUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterInviteExternalUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterOwnGroups</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ConnectOrgToEnvironmentHub</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ContentAdministrator</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ContentWorkspaces</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ConvertLeads</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeFilters</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateDashboardFolders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreatePackaging</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateReductionOrder</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateReportFolders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateWorkBadgeDefinition</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateWorkspaces</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CustomizeApplication</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>DataExport</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>DelegatedTwoFactor</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>DeleteActivatedContract</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>DeleteTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>DistributeFromPersWksp</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditActivatedOrders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditBillingInfo</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditBrandTemplates</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditCaseComments</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditEvent</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditHtmlTemplates</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditKnowledge</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditMyDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditMyReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditOppLineItemUnitPrice</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditPublicDocuments</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditPublicFilters</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditPublicTemplates</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditReadonlyFields</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditTask</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EmailMass</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EmailSingle</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EnableCommunityAppLauncher</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EnableNotifications</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ExportReport</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>FieldServiceAccess</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ImportCustomObjects</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ImportLeads</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ImportPersonal</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>InboundMigrationToolsUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>InstallPackaging</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>LightningConsoleAllowedForUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>LightningExperienceUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ListEmailSend</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageAnalyticSnapshots</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageAuthProviders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageBusinessHourHolidays</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCallCenters</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCases</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCategories</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCertificates</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageContentPermissions</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageContentProperties</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageContentTypes</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCssUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCustomPermissions</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageCustomReportTypes</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageDashbdsInPubFolders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageDataCategories</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageDataIntegrations</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageDynamicDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageEmailClientConfig</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageEntitlements</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageExchangeConfig</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageHealthCheck</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageInteraction</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageInternalUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageIpAddresses</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageKnowledge</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageKnowledgeImportExport</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageLeads</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageLoginAccessPolicies</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageMobile</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageNetworks</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManagePackageLicenses</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManagePartnerNetConn</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManagePartners</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManagePasswordPolicies</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageProfilesPermissionsets</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManagePvtRptsAndDashbds</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageQuotas</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageRemoteAccess</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageReportsInPubFolders</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageRoles</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageSandboxes</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageSearchPromotionRules</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageSharing</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageSolutions</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageSynonyms</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageTerritories</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageTranslation</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageUnlistedGroups</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ManageUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>MassInlineEdit</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>MergeTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ModerateChatter</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ModifyAllData</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ModifyMetadata</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>NewReportBuilder</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>OutboundMigrationToolsUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>OverrideForecasts</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>Packaging2</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>PublishPackaging</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>RemoveDirectMessageMembers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ResetPasswords</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>RunReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ScheduleJob</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ScheduleReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SelectFilesFromSalesforce</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SendSitRequests</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ShareInternalArticles</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ShowCompanyNameAsUserBadge</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SocialInsightsLogoAdmin</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SolutionImport</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubmitMacrosAllowed</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubscribeDashboardToOtherUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubscribeReportToOtherUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubscribeReportsRunAsUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubscribeToLightningDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubscribeToLightningReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>TagManager</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>TransferAnyCase</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>TransferAnyEntity</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>TransferAnyLead</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>UseTeamReassignWizards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>UseWebLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewAllData</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewAllForecasts</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewAllUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewDataAssessment</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewDataCategories</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewEventLogFiles</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewHealthCheck</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewHelpLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewMyTeamsDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewPublicDashboards</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewPublicReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewRoles</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewSetup</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>WorkCalibrationUser</name>
    </userPermissions>
    
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
