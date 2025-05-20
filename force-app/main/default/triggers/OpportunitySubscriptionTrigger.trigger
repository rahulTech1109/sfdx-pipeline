trigger OpportunitySubscriptionTrigger on Opportunity (after update) {
    if(trigger.isUpdate && trigger.isAfter){
        OppotunitySubscriptionHandler.createRespectiveSubscription(Trigger.new, Trigger.OldMap);
    }
}