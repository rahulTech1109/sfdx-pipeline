/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 02-20-2025
 * @last modified by  : aro.rahul@concret.io
**/
@isTest
public with sharing class DemoClass_Test {

    @TestSetup
    static void makeData(){
       List<Case> caseList = TestDataFactory.createCases(3);
    insert caseList;
    }

    @isTest
    public static void multiplyDigits_Post() {
       Test.startTest();
         Integer a = 5;
         Integer b= 10;
         DemoClass obj = new DemoClass();
        Integer res  = obj.mulitipleDigits(a,b);
        Test.stopTest();
        Assert.areEqual(50, res, 'The result should be 50');
    }

    @isTest
    public static void updatedCase_Post(){
        List<Case> caseList = [SELECT ID, Subject FROM Case  WHERE Subject = 'Hi There'];
        Test.startTest();
        DemoClass obj = new DemoClass();
        obj.CaseUpdates(caseList[0]);
        Test.stopTest();
        Assert.areEqual('Case Updated', caseList[0].Subject, 'The subject should be updated');
    }

}