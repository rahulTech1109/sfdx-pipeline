@isTest
public class RetrivebillingCycleTest {
    @isTest
    static void testGetTodayBillCycles() {
        // Setup test data
        BillCycle__c testBillCycle1 = new BillCycle__c(Name = 'Test Cycle 1');
        BillCycle__c testBillCycle2 = new BillCycle__c(Name = 'Test Cycle 2');

        // Insert the records
        insert new List<BillCycle__c> { testBillCycle1, testBillCycle2 };

        // Call the method to retrieve records by name
        List<BillCycle__c> retrievedBillCycles = RetrivebillingCycle.getTodayBillCycles('Test Cycle 1');
        
        // Verify the results
        System.assertEquals(1, retrievedBillCycles.size(), 'There should be 1 record retrieved.');
        System.assertEquals('Test Cycle 1', retrievedBillCycles[0].Name, 'The retrieved record name should match.');

        // Test for a name that doesn't exist
        List<BillCycle__c> emptyResult = RetrivebillingCycle.getTodayBillCycles('Nonexistent Cycle');
        System.assertEquals(0, emptyResult.size(), 'There should be no records retrieved for a nonexistent name.');
    }
}