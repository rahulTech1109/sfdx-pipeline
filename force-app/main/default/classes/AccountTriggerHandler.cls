/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 12-30-2024
 * @last modified by  : aro.rahul@concret.io
**/
public class AccountTriggerHandler {
    public static void closeAllOpportunity(Map<Id, Account> newAccountRecords) {
       List<Opportunity> opportunitiesTobeUpdates = [SELECT ID, StageName From Opportunity WHERE AccountID IN :newAccountRecords.keySet() 
        AND StageName != 'Closed Won' AND CreatedDate = Today];

        for(Opportunity opp : opportunitiesTobeUpdates) {
            opp.StageName = 'Closed Won';
        }

        update opportunitiesTobeUpdates;
    }
    public static void preventAcccountdeletion(Map<Id,Account> idVsAccountMap){
        for(Account acc : idVsAccountMap.values()){
            if(acc.Active__c == 'YES'){
                acc.addError('You cannot delete this account because it is in active state');
            }
        }
    }
}