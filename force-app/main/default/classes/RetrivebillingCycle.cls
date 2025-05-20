public class RetrivebillingCycle {
      public static List<BillCycle__c> getTodayBillCycles(String name) {
          return [SELECT Id, Name, CreatedDate FROM BillCycle__c WHERE Name = :name];
    }
}