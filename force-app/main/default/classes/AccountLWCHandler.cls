/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 05-06-2025
 * @last modified by  : aro.rahul@concret.io
**/
public with sharing class AccountLWCHandler {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAccountsData(Id accountId){
        return [SELECT ID, FIRSTNAME,LASTNAME, EMAIL ,PHONE FROM CONTACT WHERE ACCOUNTID = :accountId WITH USER_MODE];
    }
}