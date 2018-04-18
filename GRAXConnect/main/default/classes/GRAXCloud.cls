/* --------------------------------------------------------------------------
 * This file is subject to the terms and conditions defined in
 * file https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE,
 * which is part of this source code package.
 * --------------------------------------------------------------------------
 *          Copyright (c) 2017-2018 Harding Point
 *                  All rights reserved
 * --------------------------------------------------------------------------
 * Support:	Support@Grax.io
 * Website:	https://grax.io
 * Github:	https://github.com/HardingPoint/GRAXForSFDC
 * License:	https://github.com/HardingPoint/GRAXForSFDC/blob/master/LICENSE
 * --------------------------------------------------------------------------*/

public virtual with sharing class GRAXCloud extends GRAXSettings{
	//Class that manages full communication with GRAX Cloud.

	// Constructor
    //public GRAXCloud() {	
    //}

	public static HttpResponse calloutnow(String url, String content) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setBody(content);

		GRAXCloud gx = new GRAXCloud();

		if (gx.ProperlyConfigured){
			if (url==''){
				url = gx.ApiURL;
			}

			req.setHeader('Content-Type', 'application/json');
			req.setHeader('licensetoken', gx.LicenseToken);
			req.setHeader('authorizationToken', gx.ApiToken);
			req.setHeader('x-api-key', gx.GatewayToken);
			req.setHeader('sfdcorgid', UserInfo.getOrganizationId());
		}

		req.setEndpoint(url);

		return h.send(req);
	}

	/*****************************************************************************************
	Name              : callout
	Description       : Add the sobjectName parameter when the function is called from a trigger.
	Revision History  :
	Created/Modified by   Created/Modified Date     Requested by		Related Task/Issue     
	----------------------------------------------------------------------------------------
	1. Leandro Brunner       04/18/2018				David Mackey		https://app.asana.com/0/326600806074978/633149554508924/f
	******************************************************************************************/
	public static void callout(String url, String content) {
		String sobjectName = '';

		if(Trigger.New <> null && Trigger.New[0] <> null && Trigger.New[0].Id <> null) {
			sobjectName = String.valueOf(Trigger.New[0].Id.getSobjectType());
		}

		GRAXCloud.callout(url, content, sobjectName);
	}

	/*****************************************************************************************
	Name              : callout
	Description       : Create a new "GRAX_Data_Record__c" next to your "Attachment" from the parameters,
						and try to add to the queue the process responsible for making the call. (GRAXQueueCallout)
	Revision History  :
	Created/Modified by   Created/Modified Date     Requested by		Related Task/Issue     
	----------------------------------------------------------------------------------------
	1. Leandro Brunner       04/17/2018				David Mackey		https://app.asana.com/0/326600806074978/633149554508924/f
	******************************************************************************************/
    public static void callout(String url, String content, String sobjectName) {
		GRAX_Data_Record__c dr = new GRAX_Data_Record__c();
		// dr.Salesforce_ID__c;
		dr.Salesforce_Object__c = sobjectName;
		dr.Status__c = 'Not Sent';
		dr.of_Times_Sent__c = 0;
		dr.Error_Message__c = null;
		insert dr;

		Attachment req_att = new Attachment();
		req_att.Name = 'request.txt';
		req_att.Body = Blob.valueOf(content);
		req_att.ParentId = dr.Id;
		insert req_att;

		// Verify limits before adding the callout to the queue. 
		if(Limits.getQueueableJobs() != Limits.getLimitQueueableJobs() || Test.isRunningTest()) {
			System.enqueueJob(new GRAXQueueCallout(url, content, dr));
		} else {
			dr.Status__c = 'Not Processed - Queuable Jobs Full';
			update dr;
		}
    }

	/*****************************************************************************************
	Name              : calloutnowAndUpdateDataRecord
	Description       : Make the call to the "calloutnow" function, check its result, and update the "GRAX_Data_Record__c".
	Revision History  :
	Created/Modified by   Created/Modified Date     Requested by		Related Task/Issue             
	----------------------------------------------------------------------------------------
	1. Leandro Brunner       04/17/2018				David Mackey		https://app.asana.com/0/326600806074978/633149554508924/f
	******************************************************************************************/
	public static void calloutnowAndUpdateDataRecord(String url, String content, GRAX_Data_Record__c dr) {
		try {
			HttpResponse res = GRAXCloud.calloutnow(url, content);
			
			if(String.valueOf(res.getStatusCode()).startsWith('2')) {
				dr.Status__c = 'Sent Successful';
			} else if(res <> null) {
				dr.Status__c = 'Error';
				dr.Error_Message__c = res.getBody();
			} else {
				dr.Status__c = 'Error';
				dr.Error_Message__c = 'The request could not be sent.';
			}
	
			dr.Last_Sent_Date__c = Date.today();
		} catch(Exception e) {
			dr.Error_Message__c = e.getMessage() + '\nStack Trace: ' + e.getStackTraceString() + '\nLine Number: ' + e.getLineNumber() + '\nException Type: ' + e.getTypeName();
		}

		dr.of_Times_Sent__c += 1;
		update dr;
	}


	/*****************************************************************************************
	Name              : GRAXQueueCallout
	Description       : Queueable that makes the asynchronous call to "calloutnowAndUpdateDataRecord".
	Revision History  :
	Created/Modified by   Created/Modified Date     Requested by		Related Task/Issue             
	----------------------------------------------------------------------------------------
	1. Leandro Brunner       04/17/2018				David Mackey		https://app.asana.com/0/326600806074978/633149554508924/f
	******************************************************************************************/
	public class GRAXQueueCallout implements Queueable, Database.AllowsCallouts {
		String url;
		String content;
		GRAX_Data_Record__c dataRecord;

		public GRAXQueueCallout(String url, String content, GRAX_Data_Record__c dataRecord) {
			this.url = url;
			this.content = content;
			this.dataRecord = dataRecord;	
		}

		public void execute(QueueableContext context) {
			if(url <> null && content <> null && dataRecord <> null) {
				GRAXCloud.calloutnowAndUpdateDataRecord(url, content, dataRecord);
			}
		}
	}
}
