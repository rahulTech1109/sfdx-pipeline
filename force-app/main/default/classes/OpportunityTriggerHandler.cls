/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 12-30-2024
 * @last modified by  : aro.rahul@concret.io
**/
public with sharing class OpportunityTriggerHandler {
    public static void updatedAccountAmounc(Map<Id, Opportunity> newOppRecords){
         Set<Id> accountIds = new Set<Id>();

         for(Opportunity oppObj : newOppRecords.values()){
                if(oppObj.AccountId != null){
                    accountIds.add(oppObj.AccountId);
                }
         }
         List<Account> accountToUpdate = new List<Account>();
         if(!accountIds.isEmpty()){
            List<AggregateResult> opportunityAmount = [SELECT AccountId, SUM(Amount) totalAmount FROM OPPORTUNITY WHERE ACCOUNTID IN :accountIds GROUP BY AccountId];

            for(AggregateResult ar : opportunityAmount){
                Account acc = new Account(Id = (Id)ar.get('AccountId'), AnnualRevenue = (Decimal)ar.get('totalAmount'));
                accountToUpdate.add(acc);
            }
         }
         if(accountToUpdate.size() > 0){
            update accountToUpdate;
         }
    }
}