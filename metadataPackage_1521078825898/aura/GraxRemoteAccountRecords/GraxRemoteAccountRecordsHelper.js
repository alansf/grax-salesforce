({

	loadMainSettings : function(component, helper) {

		var action = component.get('c.getMainSettings');

		action.setCallback(this, function (response) {

			if (component.isValid() && response.getState() === 'SUCCESS') {

				if (response.getReturnValue()) {

					component.set('v.mainSettings', response.getReturnValue());
				}
			}
			else {
				console.error(response);
			}
		});

		$A.enqueueAction(action);
	},

	getGraphAccounts : function(component, helper) {

		var accountId = component.get('v.recordId') ? component.get('v.recordId') : '0011N00001Cj2RO';

		var action = component.get('c.getAccounts');
		action.setParams({
			accountId: accountId
		});

		action.setCallback(this, function (response) {

			if (component.isValid() && response.getState() === 'SUCCESS') {

				var accounts = response.getReturnValue();
				var nodeIds = [];

				for (var i = 0; i < accounts.data.length; i++) {
					var nodeId = accounts.data[i][0];
					nodeIds.push(nodeId.toString());
				}

				if (nodeIds && nodeIds.length > 0) {

					helper.getGraphOpportunities(component, nodeIds);
					helper.getGraphContacts(component, nodeIds);
					helper.getGraphCases(component, nodeIds);
				}

			}
			else {
				console.error(response);
			}
		});

		$A.enqueueAction(action);
	},

	getGraphOpportunities : function(component, nodeIds) {

		var action = component.get('c.getAccountOpportunities');
		action.setParams({
			nodeIds: nodeIds
		});

		action.setCallback(this, function (response) {

			if (component.isValid() && response.getState() === 'SUCCESS') {

				var responseValue = response.getReturnValue();

				if (responseValue.data) {

					var opportunityRecords = [];

					for (var i = 0; i < responseValue.data.length; i++) {

						var data = responseValue.data[i][0].data;

						var key = Object.keys(data);
						var keys = Object.keys(data);
						var n = keys.length;

						var newobj = {};

						while (n--) {

							key = keys[n];
							newobj[key.toLowerCase()] = data[key];
						}

						opportunityRecords.push(data);
					}

					component.set('v.opportunityRecords', opportunityRecords);
				}
			}
			else {
				console.error(response);
			}
		});

		$A.enqueueAction(action);
	},

	getGraphContacts : function(component, nodeIds) {

		var action = component.get('c.getAccountContacts');
		action.setParams({
			nodeIds: nodeIds
		});

		action.setCallback(this, function (response) {

			if (component.isValid() && response.getState() === 'SUCCESS') {

				var responseValue = response.getReturnValue();

				if (responseValue.data) {

					var contactRecords = [];

					for (var i = 0; i < responseValue.data.length; i++) {

						var data = responseValue.data[i][0].data;

						var key = Object.keys(data);
						var keys = Object.keys(data);
						var n = keys.length;

						var newobj = {};

						while (n--) {

							key = keys[n];
							newobj[key.toLowerCase()] = data[key];
						}

						console.log(newobj);
						contactRecords.push(newobj);
					}

					component.set('v.contactRecords', contactRecords);
				}
			}
			else {
				console.error(response);
			}
		});

		$A.enqueueAction(action);
	},

	getGraphCases : function(component, nodeIds) {

		var action = component.get('c.getAccountCases');
		action.setParams({
			nodeIds: nodeIds
		});

		action.setCallback(this, function (response) {

			if (component.isValid() && response.getState() === 'SUCCESS') {

				var responseValue = response.getReturnValue();

				if (responseValue.data) {

					var caseRecords = [];

					for (var i = 0; i < responseValue.data.length; i++) {

						var data = responseValue.data[i][0].data;

						var key = Object.keys(data);
						var keys = Object.keys(data);
						var n = keys.length;

						var newobj = {};

						while (n--) {

							key = keys[n];
							newobj[key.toLowerCase()] = data[key];
						}

						caseRecords.push(data);
					}

					component.set('v.caseRecords', caseRecords);
				}
			}
			else {
				console.error(response);
			}
		});

		$A.enqueueAction(action);
	},

	loadLabels: function(component) {

		var action = component.get('c.getColumnLabels');

		action.setCallback(this, function (response) {

			if (component.isValid() && response.getState() === 'SUCCESS') {

				var responseValue = response.getReturnValue();

				if (responseValue.Contact) {

					var contactLabels = [];

					for (var i = 0; i < responseValue.Contact.length; i++) {

						var fieldName = responseValue.Contact[i].Field_Name__c ? responseValue.Contact[i].Field_Name__c.toLowerCase() : '';

						contactLabels.push({
							label: responseValue.Contact[i].Column_Name__c,
							fieldName: fieldName,
							type: responseValue.Contact[i].Format_Type__c,
						});
					}

					if (component.get('v.mainSettings').Display_Organization_Name__c === true) {
						contactLabels.push({label: "Organization Name", fieldName: "orgname", type: "text"});
					}

					component.set('v.contactLabels', contactLabels);
				}

				if (responseValue.Case) {

					var caseLabels = [];

					for (var i = 0; i < responseValue.Case.length; i++) {
						caseLabels.push({
							label: responseValue.Case[i].Column_Name__c,
							fieldName: responseValue.Case[i].Field_Name__c,
							type: responseValue.Case[i].Format_Type__c,
						});
					}

					if (component.get('v.mainSettings').Display_Organization_Name__c === true) {
						caseLabels.push({label: "Organization Name", fieldName: "orgname", type: "text"});
					}

					component.set('v.caseLabels', caseLabels);
				}

				if (responseValue.Opportunity) {

					var opportunityLabels = [];

					for (var i = 0; i < responseValue.Opportunity.length; i++) {
						opportunityLabels.push({
							label: responseValue.Opportunity[i].Column_Name__c,
							fieldName: responseValue.Opportunity[i].Field_Name__c,
							type: responseValue.Opportunity[i].Format_Type__c,
						});
					}

					if (component.get('v.mainSettings').Display_Organization_Name__c === true) {
						opportunityLabels.push({label: "Organization Name", fieldName: "orgname", type: "text"});
					}

					component.set('v.opportunityLabels', opportunityLabels);
				}

			}
			else {
				console.error(response);
			}
		});

		$A.enqueueAction(action);

	}
})