public class HubSpotApi{

    private static final String HUBSPOT_ACCESS_TOKEN = 'pat-na1-45e01c05-08b4-4232-9fc7-5e6660ef8511';
    private static final String HUBSPOT_API_URL = 'https://api.hubapi.com/crm/v4/objects/contact/27387367092/associations/default/contact/25253096209';
     private static final String BASE_URL = 'https://api.hubapi.com/crm/v4';

    public static void createAssociation() {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        // Set the endpoint URL
        req.setEndpoint(HUBSPOT_API_URL);
        req.setMethod('PUT');
        
        // Set headers for the request
        req.setHeader('Authorization', 'Bearer ' + HUBSPOT_ACCESS_TOKEN);
        req.setHeader('Content-Type', 'application/json');
        
        // Set the request body
        String requestBody = JSON.serialize(new Map<String, Object>{
            'fromObjectId' => '46216651',
            'toObjectId' => '46216651',
            'associationType' => 'contact_to_contact'
        });
        req.setBody(requestBody);

        try {
            // Send the request
            HttpResponse res = http.send(req);
            
            // Check the response status code
            if (res.getStatusCode() == 200) {
                System.debug('API Response: ' + res.getBody());
            } else {
                System.debug('Error Response: ' + res.getStatus() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
    public static void labledAssociation(){
                HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        // Set the endpoint URL
        req.setEndpoint(BASE_URL + '/objects/' + 'contact' + '/' + '44620376244' + '/associations/' + 'contact' + '/' + '44619001918');
        req.setMethod('PUT');
        
        // Set headers for the request
        req.setHeader('Authorization', 'Bearer ' + HUBSPOT_ACCESS_TOKEN);
        req.setHeader('Content-Type', 'application/json');
        
        // Set the request body
        String requestBody = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'associationCategory' => 'USER_DEFINED',
                'associationTypeId' =>53
            }
        });
        req.setBody(requestBody);

        try {
            // Send the request
            HttpResponse res = http.send(req);
            
            // Check the response status code
            if (res.getStatusCode() == 200) {
                System.debug('API Response: ' + res.getBody());
            } else {
                System.debug('Error Response: ' + res.getStatus() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

}