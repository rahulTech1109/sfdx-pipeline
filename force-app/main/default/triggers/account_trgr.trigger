/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 05-20-2025
 * @last modified by  : aro.rahul@concret.io
**/
trigger account_trgr on Account (after update) {
    if(trigger.isAfter && trigger.isUpdate){
        System.debug('Account Trigger: After Update');
    }
}