trigger GRAXAccount on Account (after update,after insert,after delete,after undelete) {
    // -------------------------------------------------
    // https://GRAX.io/
    // Support Contact - Support At HardingPoint.com
    // -------------------------------------------------
    try {
        String url = 'https://prod.hardingpoint.com/v9.3/api';
        String content = GRAXApi.jsonContent(Trigger.new, Trigger.old);
        GRAXApi.callout(url, content);
    } catch(exception ex) {
        // Handle all exceptions want to avoid breaking customers salesforce.
        System.debug('[Trigger GRAXAccount] ' + ex.getMessage());
    }
}