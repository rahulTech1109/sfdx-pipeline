/**
 * @description       : 
 * @author            : aro.rahul@concret.io
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : aro.rahul@concret.io
**/

/**
 * https://concretio-1a-dev-ed.develop.my.salesforce.com/services/apexrest/hubSpot/
 */
@RestResource(urlMapping='/hubSpot')
global with sharing class HubSpotResourceHandler {
    @HTTPPost
    global static void getHubSpotData(){
        System.debug('Get Data Called');
    }
}