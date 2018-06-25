![GRAX by Harding Point](https://static.wixstatic.com/media/fa96ca_4cb02045be8445468545da7de475da38~mv2.png/v1/fill/w_334,h_128,al_c,usm_0.66_1.00_0.01/fa96ca_4cb02045be8445468545da7de475da38~mv2.png)

# GRAX Salesforce [![Build Status](https://travis-ci.org/HardingPoint/grax-salesforce.svg?branch=master)](https://travis-ci.org/HardingPoint/grax-salesforce)


[GRAX](https://www.grax.io/) Salesforce uses your Salesforce instance(s) to backup, archive, and maintain your
enterprise storage. GRAX allows you to capture every field change, complete object time machine, and report within
Salesforce. Please contact GRAX support team at support@grax.io, join the [SLACK](https://join.slack.com/t/grax-engineering/shared_invite/enQtMzY2NDM5NzYyODY5LTE2Y2IyOGFkNmZlNzk3ZDBkNDA1NWI3NjZlOGZkODk5OTIzNjkxZjczZGM4YTI5NDA1OGVjMTU4NGM4ZmNiNTA)
channel, or chat on [![grax.io](https://www.grax.io/).

---------------------------------------------------------------------------------------------------------
## Installation

For any questions, please contact us at support@grax.io

Notes: 
There are two installation paths. 
	1. GRAX Enterprise (Includes Graph Database) 
	2. GRAX Archiver & Audit - The following instructions are for Archiver + Audit. 
	
The GRAX Installation consists of three main steps:


1. Deploy Amazon S3 Bucket and Elastic Search Instance
2. Deploy Heroku GRAX App, Proxy & Odata Connector
3. Deploy & Configure GRAX Salesforce App

## GRAX Salesforce APP

1. Deploy GRAX APP for Salesforce:
	1. Click "Deploy GRAX to Salesforce" button
	<a href="https://deploytosalesforce.herokuapp.com?owner=HardingPoint&repo=grax-salesforce">
<img alt="Deploy to Salesforce" src="https://deploytosalesforce.herokuapp.com/resources/img/deploy-to-salesforce3.png"></a>

	2. Allow GRAX Application Access to Salesforce 
	3. Click deploy in the upper right corner. Wait for deployment to finish and log back into Salesforce. 
	4. Before continuning with the configuration of GRAX in Salesforce, Amazon S3 and Elastic Search instances need to be created.

## Amazon S3 Configuration 

1. If not already existing, create Amazon S3 bucket. Note Access, secret keys, bucket, region
    1. https://s3.console.aws.amazon.com/s3/

## Create Elastic Search Service

1. Create Elastic Search Service. 
	1. https://www.elastic.co/cloud/elasticsearch-service
	2. After creating account click "Create Deployment" 
	3. Specify Deployment Name, leave all other settings default and click "Create Deployment" 
	4. After service has been created, note the following values:
		a) Elastic Search URL under Endpoints of your deployment. 
		b) Under Security reset the passwford for your 'elastic' user. Note the password. 


## Configure Salesforce & Heroku

1. Configure Salesforce 
    1. In the App Launacher, search for GARX. Click on GRAX Settings--> Configuration --> Authorize Heroku. You should see "Connected" 
    2. Click "Create New GRAX App" New window will open. 
 	2. Specify your App name
 	3. Deploy App
    3. Once Heroku deployment complete, go back to Salesforce GRAX app, refresh and select your newly created app. Click save button. You will now see GRAX settings data populated. 
    4. Click Unlock. Under Advanced settings, update API url with 
	2. https://<<YOUR HEROKU APP NAME>>.herokuapp.com/graxproxy/api - for Audit & Archive 
	3. In another tab in Salesforce settings to go Setup->Security->Remote site settings and add the proxy URL above. Name: "GRAX_Proxy"
2. Go to GRAX Connect Tab. 
    1. Select SF Object. Check Enable audit Trail. Select fields as necessary. 
    2. Save Field Choices 
    3. Process history 
    4. Deploy Trigger 
    5. Connect SF Object selected in step 1 to graph (trigger) 
3.1 Go to the Audit Trail Tab
    1. Validate that correct postgres URL is prefilled out. Slide "Enable Field Level Tracking".  
    2. Click "Deploy partitions". Refresh page. You should see "Deploy Partitions" greyed out next to "Drop Partitions" 
    3. Slide "Enable Object Level Tracking." Fill in S3 credentials below.  
4. Go to SF Object and edit. Must be one of the fields you are syncing from step 5.1
5. Go to your Heroku Dash board and select the App that you have created in step 2. 
6. [Optional: go to S3 and check your bucket. There should be a GRAX entry) 

7. 1. Go To your Heroku app and open Heroku Connect. 
    2. In the overview tab click setup connection. 
    3. Schema name will defailt to Salesforce, click next. 
    4. Authorize. 
    5. Login to your Salesforce environment. 
    6. Go back to Heroku Connect and click  the "External Objects" tab
    7. Click create credentials. 
    8. Note the service URL, username and password. This will be used in the next step. 
    9. Open your Heroku Connect app and click on the tab of your app name. 
    10. Click on setup connection 
    11. On the "Provision Connection" page leave the values as is, click next. 
    12. On the "Authorize Connection" page click "Authorize" 
    13. Salesforce login page will open, login and "Authorize" 
    14. In your Heroku Connect App click on the "External Objects" Tab and click "Create Credentials" 
    15. Note the server URL. Refresh page. 
    16. Under Data Sources you should see "auditlog" followed by "auditlog_pxxxxx". Click shared for "auditlog" 
    

8. In Salesforce Go Setup —> SF External Data Sources. 
    1. Click New External Data Source
    2. Enter Name "GRAX:Audit Trail" 
    3. Enter type Data 4.0
    4. [For Enterprise Only] Validate that your OData Connector works-  https://<<REPLACE WITH YOUR APP NAME>>.herokuapp.com/grax.svc/$metadata ]
    5.1 [For Enterprise Only] Enter URL: https://<<REPLACE WITH YOUR APP NAME>>.herokuapp.com/grax.svc/ - This is for GRAPH Odata Connector (Enterprise) 
    5.2 Enter URL: from step 10.8  - This is your Heroku Connect URL
    5.3 Under Authentication set Identity Type to "Named Principal" and Authentication Protocol to "Password Authentication". Enter the username and password from 10.8 
    6. Leave all other settings unchanged. click save. 
    7. Click on Validate and Sync.
9. You should see one item: "grax$auditlog" 
    1. Click Sync. 
10. Go to External Objects. Edit ‘AuditLog’ 
    1. Optional Features —> Check allow reports
	2. Update Deployment Status to "Deployed"
    3. Save
	   1. Under External Object Definition Detail click Edit
	   2. Update Label & Plural Label from ‘grax$auditlog’ --> "GRAX Audit Log". Check Allow Reports. 
    7. Make sure all is set to visible. 
    8. Repeat for all desired AuditLog Custom Fields. 
11. Go to SF Reports. 
    1. Click on New Report
    2. Search for AuditLog and click on it
    3. Click Create
    4. Drag Audit Log Columns into the preview. 
    5. In the top left corner click Save. 
    6. Run report. 
12. Optional: Now you can sync more SF Objects. Follow steps 5
13. Setting up External Object to show Audit Log Records in related tab: 

1. Click on the Label “grax$auditlog” under external objects 
2. copy the value ‘objectid’
3. under custom fields & relationships click the new button 
4. lookup relationship —> next 
5. related to SF Objectt
6. External Column name 
7. make all visible 
8. Navigate to Sales --> your Salesorce Object that you want to show the Audot Log in the related tab. 
9. Switch to classic. 
10. In the top right click on "Edit Layout" 
11. Scroll to the bottom of the page, you should see "GRAX Audit Log". Click on the wrench. 
12. Add in the following fields and update the sortby: https://www.screencast.com/t/Eh2YoOePy
13. Click save at the top of the page. 

You should now see the audit log

Configuring the backup via the GRAX UI: 
1. Go to the Back Up Tab in the GRAX application. 
2. CLick Create 
3. Select your Salesforce Object
4. Define other backup criteria as outlined on the page. (UI Updates are coming) 
5. Run this script to force a backup: 


```
//--------------------------
//Code to fire the Schedule Processes now       
        
        List<GRAX_Schedule_Process__c> schedProcesses2Up = new List<GRAX_Schedule_Process__c>();
       
        // Find any Schedule Process Job that is supposed to run at the current GMT time, 
        // or that it hasn't been executed on the previous Schedule run and it's not currently executing
        for(GRAX_Schedule_Process__c schedProcess : [SELECT Id, Status__c FROM GRAX_Schedule_Process__c WHERE Next_Run_Date__c <=: System.now() AND Status__c <> 'Running']){
            GRAXBatchToProcessSchedJob b = new GRAXBatchToProcessSchedJob(schedProcess.Id, null, 0, null);
            
            try{
                // Check if the call to "executebatch" failed to acquire an Apex flex queue lock
                Id jobId = Database.executebatch(b, 1000);
                schedProcess.Status__c = 'Running';
            }catch(System.AsyncException e){
                schedProcess.Status__c = 'Error';
            }
            
            schedProcesses2Up.add(schedProcess);
        }        
        
        if(schedProcesses2Up.size() > 0){
            update schedProcesses2Up;
        }
        
//--------------------------
```


## Deploy GRAX Proxy

The purpose of the standalone GRAX proxy is to have that separated from your main Heroku GRAX app for scalability and resourcing. 

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://www.heroku.com/deploy/?template=https://github.com/HardingPoint/grax-proxy-secure)

1. Enter app name
2. Go to your GRAX Salesforce app and retrieve the postgres URL from settings to enter DATABASE_URL
3. Enter Elastic Search Password noted earlier. 
4. Enter FOUNDELASTICSEARCH_URL
5. Click Deploy

## Deploy GRAX OData Connector

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://www.heroku.com/deploy/?template=https://github.com/HardingPoint/grax-odata-secure)

1. Enter app name
2. Enter Elastic Search Password noted earlier. 
3. Enter FOUNDELASTICSEARCH_URL and remove https and port.
4. Click Deploy
	

## Heroku Scheduler

    Add New Scheduled Task to Heroku to Run Daily at Midnight.
    
    heroku run 'psql $DATABASE_URL -c "select run_maintenance();"'
