

@isTest
private class GRAXSettingsUT {
    
    @isTest
    static void ConstructorTest() {
    		GRAXSettings.debug('ConstructorTest', 'Unit Test', '',1);
        GRAXSettings gxs = new GRAXSettings();
        gxs = new GRAXSettings('Account');
        gxs = new GRAXSettings('ConstructorTest', 'Account');
    }
    
    @isTest
    static void IsConfigured() {
    		GRAXSettings.debug('IsConfigured', 'Unit Test', '',1);
        GRAXSettings.IsConfigured();
    }
    
    @isTest
    static void GetSynchedObjects() {
    		GRAXSettings.debug('GetSynchedObjects', 'Unit Test', '',1);
    		GRAXSettings gxs = new GRAXSettings();
        GRAXQuery__c query = gxs.getSynchedObject('Account');
    }
    
    @isTest
    static void GetSynchedObjectsMap() {
    		GRAXSettings.debug('GetSynchedObjectsMap', 'Unit Test', '',1);
    		Map<String,GRAXQuery__c> gxq = GRAXSettings.getSynchedObjects();
    }
    
}
