/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 02-20-2025
 * @last modified by  : aro.rahul@concret.io
**/
public with sharing class DemoClass {
   public Integer mulitipleDigits(Integer a, Integer b) {
      Integer c = a * b;
      return c;
    }

    public void CaseUpdates(Case caseToUpdate){
        caseToUpdate.Subject = 'Case Updated';
        update caseToUpdate;
    }
}