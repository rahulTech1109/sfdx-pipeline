/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 04-21-2025
 * @last modified by  : aro.rahul@concret.io
**/
public with sharing class OpportunityLineItemHandler {
   public static void handleAfterInsert(List<OpportunityLineItem> newLineItems){
     Set<Id> OpportunityIds = new Set<Id>();
        for(OpportunityLineItem lineItem : newLineItems){
            OpportunityIds.add(lineItem.OpportunityId);
        }
     
        Map<Id,Integer> OpportunityIdsVsLineItemCount = new Map<Id,Integer>();

        List<AggregateResult> results = [SELECT OpportunityId, COUNT(ID) lineItemCount FROM OPPORTUNITYLINEITEM WHERE OPPORTUNITYID IN :OpportunityIds GROUP BY OpportunityId];

       for(AggregateResult result : results){
            OpportunityIdsVsLineItemCount.put((Id)result.get('OpportunityId'), (Integer)result.get('lineItemCount'));
        }

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        
    }
   public static void handleAfterDelete(List<OpportunityLineItem> oldLineItems){

   }
}