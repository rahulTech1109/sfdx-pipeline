public class OppotunitySubscriptionHandler {
    public static void createRespectiveSubscription(List<Opportunity> newOppRecords, Map<ID,Opportunity> oldOppwithID){
        List<Opportunity> updatedOpportunity = new List<Opportunity>();
        for(Opportunity oppObj: newOppRecords){
            Opportunity oldObj = oldOppwithID.get(oppObj.Id);
            if(oppObj.StageName == 'Closed Won' &&  oppObj.StageName != oldObj.StageName){
                updatedOpportunity.add(oppObj);
            }
        }
        if(updatedOpportunity.IsEmpty()){
            return;
        }
        
        List<Ketive_Subscription__c> ketiveSubscriptions = new List<Ketive_Subscription__c>();
        List<Ansys_Subscription__c> ansysSubscriptions = new List<Ansys_Subscription__c>();
        List<Misc_Subscription__c> miscSubscriptions = new List<Misc_Subscription__c>();
        List<Opportunity> opportunityRecordswithLineItems = [SELECT Id , AccountId , CloseDate , StageName , 
                                                             (SELECT Id,ListPrice,Name,Quantity,UnitPrice,Type__c,TotalPrice,ServiceDate 
                                                              FROM OpportunityLineItems) 
                                                             FROM Opportunity WHERE ID IN :updatedOpportunity];
        
        for(Opportunity oppObj : opportunityRecordswithLineItems){
            for(OpportunityLineItem lineItemObj : oppObj.OpportunityLineItems){
                if(lineItemObj.type__c == 'Ketive'){
                    Ketive_Subscription__c newKetiveSubscription = new Ketive_Subscription__c(
                        KETIVE_SUBSCRIPTION__C = oppObj.AccountId,   // Link to Account
                        Name = lineItemObj.Name,
                        Unit_Price__c = lineItemObj.ListPrice,
                        Status__c = 'Active'
                    );                       
                    ketiveSubscriptions.add(newKetiveSubscription);
                }
                else if(lineItemObj.type__c == 'Ansys'){
                    Ansys_Subscription__c newAnsysSubscritpion = new Ansys_Subscription__c(
                        	Ansys_Subscription__c = oppObj.AccountId,
                            Name = lineItemObj.Name,
                            Unit_Price__c = lineItemObj.ListPrice,
                            Status__c = 'Active'
                    );
                    ansysSubscriptions.add(newAnsysSubscritpion);
                }
                else{
                    Misc_Subscription__c  newMiscSubscription = new Misc_Subscription__c(
                            Account__c = oppObj.AccountId,
                            Name = lineItemObj.Name,
                            Unit_Price__c = lineItemObj.ListPrice,
                            Status__c = 'Active'
                    );
                    miscSubscriptions.add(newMiscSubscription);
                }
            }
        }
         system.debug('Runing-48');
        if(!ketiveSubscriptions.IsEmpty()){
            INSERT ketiveSubscriptions;
        }
        if(!ansysSubscriptions.IsEmpty()){
            INSERT ansysSubscriptions;
        }
        if(!miscSubscriptions.IsEmpty()){
            INSERT miscSubscriptions;
        }
    }
}