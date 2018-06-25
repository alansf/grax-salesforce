/*****************************************************************************************
Name              : GRAXDataRecordTriggerHandler
Description       : -
Revision History  :
Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Ariel Yankelevich       06/06/2018           David Mackey        Backup and Restore Notes & Attachments (https://app.asana.com/0/326600806074978/692982800286805/f)
******************************************************************************************/

public with sharing class GRAXDataRecordTriggerHandler {
	
    public static void triggerExecute(){        
        if(Trigger.isAfter){
        	if(Trigger.isInsert){
        		rollUpTotalRecordsToProcess();
                rollUpTotalAsyncRecordsToProcess();
            }else if(Trigger.isUpdate){
                rollUpTotalRecordsSuccessfullySent();
        		rollUpTotalAsyncRecordsSuccessfullySent();  
        	}else if(Trigger.isDelete){
        		rollUpTotalRecordsToProcess();
                rollUpTotalAsyncRecordsToProcess();
        	}else if(Trigger.isUndelete){
        		rollUpTotalRecordsToProcess();
                rollUpTotalAsyncRecordsToProcess();
        	}            
        }
    }
    
    public static Set<String> GRAXArchiveProcRollupFields = new Set<String>();
    private static Set<String> asyncObjects2ProcessByGRAX = new Set<String>{'Attachment', 'ContentVersion'};
    
    /*******************************************************************************
    Name              : rollUpTotalRecordsToProcess
    Description       : Counts the total number of GRAX Data Records that will be archived
    Events            : after insert, after delete, after undelete
    Revision History  : - 
    Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue  
    ----------------------------------------------------------------------------------------
    1. Ariel Yankelevich       06/06/2018           David Mackey        Backup and Restore Notes & Attachments (https://app.asana.com/0/326600806074978/692982800286805/f)
	*******************************************************************************/
    
    public static void rollUpTotalRecordsToProcess(){
        Map<Id, GRAX_Archive_Process__c> counterByArchiveProc = new Map<Id, GRAX_Archive_Process__c>();
        
        for(Integer i = 0; i < Trigger.size; i++){
            if(Trigger.isInsert || Trigger.isUndelete){
                GRAX_Data_Record__c triggerNew = (GRAX_Data_Record__c)Trigger.new[i];
                
                Boolean condition = triggerNew.GRAX_Archive_Process__c <> null;
                
                if(condition){
                    if(!counterByArchiveProc.containsKey(triggerNew.GRAX_Archive_Process__c)){
                        counterByArchiveProc.put(triggerNew.GRAX_Archive_Process__c, new GRAX_Archive_Process__c(Id = triggerNew.GRAX_Archive_Process__c, Records_To_Process__c = 0));
                    }
                    GRAX_Archive_Process__c archiveProc = counterByArchiveProc.get(triggerNew.GRAX_Archive_Process__c);
                    archiveProc.Records_To_Process__c += 1;    			
                }
            }else if(Trigger.isDelete){
            	GRAX_Data_Record__c triggerOld = (GRAX_Data_Record__c)Trigger.old[i];
    		
                Boolean condition = triggerOld.GRAX_Archive_Process__c <> null;
                
                if(condition){
                    if(!counterByArchiveProc.containsKey(triggerOld.GRAX_Archive_Process__c)){
                        counterByArchiveProc.put(triggerOld.GRAX_Archive_Process__c, new GRAX_Archive_Process__c(Id = triggerOld.GRAX_Archive_Process__c, Records_To_Process__c = 0));
                    }
                    GRAX_Archive_Process__c archiveProc = counterByArchiveProc.get(triggerOld.GRAX_Archive_Process__c);
                    archiveProc.Records_To_Process__c += -1;    			
                }
            }  
    	}
        
        if(!counterByArchiveProc.isEmpty()){
            GRAXArchiveProcRollupFields.add('Records_To_Process__c');
            update counterByArchiveProc.values();
            GRAXArchiveProcRollupFields.remove('Records_To_Process__c');
        }
    }
    
    
    /*******************************************************************************
    Name              : rollUpTotalAsyncRecordsToProcess
    Description       : Counts the total number of Async GRAX Data Records that will be archived
    Events            : after update
    Revision History  : - 
    Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue  
    ----------------------------------------------------------------------------------------
    1. Ariel Yankelevich       06/06/2018           David Mackey        Backup and Restore Notes & Attachments (https://app.asana.com/0/326600806074978/692982800286805/f)
	*******************************************************************************/
    
    public static void rollUpTotalAsyncRecordsToProcess(){
        Map<Id, GRAX_Archive_Process__c> counterByArchiveProc = new Map<Id, GRAX_Archive_Process__c>();
        
        for(Integer i = 0; i < Trigger.size; i++){
            if(Trigger.isInsert || Trigger.isUndelete){
                GRAX_Data_Record__c triggerNew = (GRAX_Data_Record__c)Trigger.new[i];
                
                Boolean condition = triggerNew.GRAX_Archive_Process__c <> null;
                condition &= asyncObjects2ProcessByGRAX.contains(triggerNew.Salesforce_Object__c);
                
                if(condition){
                    if(!counterByArchiveProc.containsKey(triggerNew.GRAX_Archive_Process__c)){
                        counterByArchiveProc.put(triggerNew.GRAX_Archive_Process__c, new GRAX_Archive_Process__c(Id = triggerNew.GRAX_Archive_Process__c, Async_Records_to_Process__c = 0));
                    }
                    GRAX_Archive_Process__c archiveProc = counterByArchiveProc.get(triggerNew.GRAX_Archive_Process__c);
                    archiveProc.Async_Records_to_Process__c += 1;    			
                }
            }else if(Trigger.isDelete){
            	GRAX_Data_Record__c triggerOld = (GRAX_Data_Record__c)Trigger.old[i];
    		
                Boolean condition = triggerOld.GRAX_Archive_Process__c <> null;
                condition &= asyncObjects2ProcessByGRAX.contains(triggerOld.Salesforce_Object__c);
                
                if(condition){
                    if(!counterByArchiveProc.containsKey(triggerOld.GRAX_Archive_Process__c)){
                        counterByArchiveProc.put(triggerOld.GRAX_Archive_Process__c, new GRAX_Archive_Process__c(Id = triggerOld.GRAX_Archive_Process__c, Async_Records_to_Process__c = 0));
                    }
                    GRAX_Archive_Process__c archiveProc = counterByArchiveProc.get(triggerOld.GRAX_Archive_Process__c);
                    archiveProc.Async_Records_to_Process__c += -1;    			
                }
            }  
    	}
        
        if(!counterByArchiveProc.isEmpty()){
            GRAXArchiveProcRollupFields.add('Async_Records_to_Process__c');
            update counterByArchiveProc.values();
            GRAXArchiveProcRollupFields.remove('Async_Records_to_Process__c');
        }
    }    
    
    
    /*******************************************************************************
    Name              : rollUpTotalRecordsSuccessfullySent
    Description       : Counts the total number of GRAX Data Records that were Successfully Sent to GRAX
    Events            : after update
    Revision History  : - 
    Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue  
    ----------------------------------------------------------------------------------------
    1. Ariel Yankelevich       06/06/2018           David Mackey        Backup and Restore Notes & Attachments (https://app.asana.com/0/326600806074978/692982800286805/f)
	*******************************************************************************/
    
    public static void rollUpTotalRecordsSuccessfullySent(){
        Map<Id, GRAX_Archive_Process__c> counterByArchiveProc = new Map<Id, GRAX_Archive_Process__c>();
        
        for(Integer i = 0; i < Trigger.size; i++){
            GRAX_Data_Record__c triggerNew = (GRAX_Data_Record__c)Trigger.new[i];
            GRAX_Data_Record__c triggerOld = (GRAX_Data_Record__c)Trigger.old[i];
                
            Boolean condition = triggerNew.Status__c == 'Sent Successful';
            condition |= triggerOld.Status__c == 'Sent Successful';
            condition &= triggerNew.GRAX_Archive_Process__c <> null;
            condition &= triggerNew.Status__c <> triggerOld.Status__c;            
            
            if(condition){
                Double counter = 1;
                if(triggerOld.Status__c == 'Sent Successful'){
                    counter = -1;
                }
                
                if(!counterByArchiveProc.containsKey(triggerNew.GRAX_Archive_Process__c)){
                    counterByArchiveProc.put(triggerNew.GRAX_Archive_Process__c, new GRAX_Archive_Process__c(Id = triggerNew.GRAX_Archive_Process__c, Records_Successfully_Sent__c = 0));
                }
                GRAX_Archive_Process__c archiveProc = counterByArchiveProc.get(triggerNew.GRAX_Archive_Process__c);
                archiveProc.Records_Successfully_Sent__c += counter;    			
            }
    	}
        
        if(!counterByArchiveProc.isEmpty()){
            GRAXArchiveProcRollupFields.add('Records_Successfully_Sent__c');
            update counterByArchiveProc.values();
            GRAXArchiveProcRollupFields.remove('Records_Successfully_Sent__c');
        }
    }
    
    
    /*******************************************************************************
    Name              : rollUpTotalAsyncRecordsSuccessfullySent
    Description       : Counts the total number of Asyn GRAX Data Records that were Successfully Sent to GRAX
    Events            : after update
    Revision History  : - 
    Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue  
    ----------------------------------------------------------------------------------------
    1. Ariel Yankelevich       06/06/2018           David Mackey        Backup and Restore Notes & Attachments (https://app.asana.com/0/326600806074978/692982800286805/f)
	*******************************************************************************/
    
    public static void rollUpTotalAsyncRecordsSuccessfullySent(){
        Map<Id, GRAX_Archive_Process__c> counterByArchiveProc = new Map<Id, GRAX_Archive_Process__c>();
        
        for(Integer i = 0; i < Trigger.size; i++){
            GRAX_Data_Record__c triggerNew = (GRAX_Data_Record__c)Trigger.new[i];
            GRAX_Data_Record__c triggerOld = (GRAX_Data_Record__c)Trigger.old[i];
                
            Boolean condition = triggerNew.Records_To_Process__c <> triggerOld.Records_To_Process__c;
            condition |= triggerNew.Records_Sent_to_GRAX__c <> triggerOld.Records_Sent_to_GRAX__c;
            condition &= triggerNew.GRAX_Archive_Process__c <> null; 
            condition &= asyncObjects2ProcessByGRAX.contains(triggerNew.Salesforce_Object__c);
            condition &= triggerNew.Records_To_Process__c == triggerNew.Records_Sent_to_GRAX__c;
            condition &= triggerNew.Records_To_Process__c > 0;
            
            if(condition){
                if(!counterByArchiveProc.containsKey(triggerNew.GRAX_Archive_Process__c)){
                    counterByArchiveProc.put(triggerNew.GRAX_Archive_Process__c, new GRAX_Archive_Process__c(Id = triggerNew.GRAX_Archive_Process__c, Async_Records_Successfully_Sent__c = 0));
                }
                GRAX_Archive_Process__c archiveProc = counterByArchiveProc.get(triggerNew.GRAX_Archive_Process__c);
                archiveProc.Async_Records_Successfully_Sent__c += 1;    			
            }
    	}
        
        if(!counterByArchiveProc.isEmpty()){
            GRAXArchiveProcRollupFields.add('Async_Records_Successfully_Sent__c');
            update counterByArchiveProc.values();
            GRAXArchiveProcRollupFields.remove('Async_Records_Successfully_Sent__c');
        }
    }
}