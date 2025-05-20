/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 02-20-2025
 * @last modified by  : aro.rahul@concret.io
**/
public with sharing class TestDataFactory {
    public static List<Case> createCases(Integer numberofCases){
        List<Case> caseList = new List<Case>();
        for(Integer i = 0; i < numberofCases; i++){
            Case newCase = new Case(Subject = 'Hi There');
            caseList.add(newCase);
        }
        return caseList;
    }
}