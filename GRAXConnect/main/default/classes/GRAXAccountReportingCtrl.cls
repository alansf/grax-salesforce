public with sharing class GRAXAccountReportingCtrl {
    List<GRAX_Account_Reporting_Setting__mdt> gars;
    public String filterValue {get;set;}

    public GRAXAccountReportingCtrl(ApexPages.StandardController stdCtrl) {
        stdCtrl.addFields(new List<String>{'Name'});
        
        Account acc = (Account)stdCtrl.getRecord();
        filterValue = acc.Name;
    }

    public List<GRAX_Account_Reporting_Setting__mdt> getSettings() {
        List<GRAX_Account_Reporting_Setting__mdt> garsList = [SELECT Report_ID__c, size__c, cacheResults__c, Filter_Key__c, Filter_Key_Id__c, filterKeyIndex__c FROM GRAX_Account_Reporting_Setting__mdt];
        
        return garsList;
    }
}
