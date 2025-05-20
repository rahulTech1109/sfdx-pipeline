/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 04-21-2025
 * @last modified by  : aro.rahul@concret.io
**/
trigger OpportunityLineItem_trgr on OpportunityLineItem (after insert, after delete) {
     if(Trigger.isAfter ){
        OpportunityLineItemHandler.handleAfterInsert(Trigger.new);
     }
     if(trigger.isDelete){
        OpportunityLineItemHandler.handleAfterDelete(Trigger.old);
     }
}