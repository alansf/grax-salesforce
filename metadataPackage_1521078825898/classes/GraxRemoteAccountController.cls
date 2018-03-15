public with sharing class GraxRemoteAccountController {

	@AuraEnabled
	public static Map<String, Object> getAccounts(Id accountId) {

		Account account = getAccount(accountId);

		Map<String, Object> result = null;

		if (account != null && account.Name != null) {

			result = Neo4jAdapter.getAccountsByName(account.Name);
		}

		return result;
	}

	@AuraEnabled
	public static GRAXSettings__c getMainSettings() {

		// return Grax_General_Settings__c.getOrgDefaults();
		return GRAXSettings__c.getOrgDefaults();
	}

	@AuraEnabled
	public static Map<String, Object> getAccountOpportunities(String[] nodeIds) {
		Map<String, Object> result = Neo4jAdapter.getAccountOpportunities(nodeIds);
		System.debug(JSON.serializePretty(result));
		return result;
	}

	@AuraEnabled
	public static Map<String, Object> getAccountContacts(String[] nodeIds) {
		Map<String, Object> result = Neo4jAdapter.getAccountContacts(nodeIds);
		System.debug(JSON.serializePretty(result));
		return result;
	}

	@AuraEnabled
	public static Map<String, Object> getAccountCases(String[] nodeIds) {
		Map<String, Object> result = Neo4jAdapter.getAccountCases(nodeIds);
		System.debug(JSON.serializePretty(result));
		return result;
	}

	@AuraEnabled
	public static Map<String, Grax_Mapped_Field__mdt[]> getColumnLabels() {

		Map<String, Grax_Mapped_Field__mdt[]> result = new Map<String, Grax_Mapped_Field__mdt[]>();

		Grax_Mapped_Field__mdt[] labels = new Grax_Mapped_Field__mdt[] {};
		labels = [SELECT
						Column_Name__c,
						Field_Name__c,
						Format_Type__c,
						Object_Name__c,
						Sort_Order__c
					FROM Grax_Mapped_Field__mdt
					WHERE Object_Name__c != null
					ORDER BY Object_Name__c, Sort_Order__c];

		for (Grax_Mapped_Field__mdt label :labels) {

			if (!result.containsKey(label.Object_Name__c)) {
				result.put(label.Object_Name__c, new Grax_Mapped_Field__mdt[] {});
			}

			// labeling with lowercase
			result.get(label.Object_Name__c).add(label);
		}

		return result;
	}

	private static Account getAccount(Id accountId) {

		Account[] result = new Account[] {};
		result = [SELECT Name FROM Account WHERE Id = :accountId];
		return result.isEmpty() ? null : result[0];
	}

}