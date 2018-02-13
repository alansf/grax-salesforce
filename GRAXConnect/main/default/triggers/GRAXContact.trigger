trigger GRAXContact on Contact (after update,after insert,after delete,after undelete) {
    // -------------------------------------------------
    // https://GRAX.io/
    // Support Contact - Support At HardingPoint.com
    // -------------------------------------------------
    try {
        String url = 'https://test.hardingpoint.com/v9.3/api';
        String content = GRAXApi.jsonContent(Trigger.new, Trigger.old);
        GRAXApi.callout(url, content);
    } catch(exception ex) {
        // Handle all exceptions want to avoid breaking customers salesforce.
        System.debug('[Trigger GRAXContact] ' + ex.getMessage());
    }
}