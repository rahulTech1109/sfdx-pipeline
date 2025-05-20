public class CalloutToHubSpot {
    public static void HubSpotWorkflowEnroll(){
        HttpRequest req = new HttpRequest();
req.setEndpoint('https://api.hubapi.com/crm/v3/objects/2-32072960');
req.setMethod('POST');
req.setHeader('Authorization', 'Bearer pat-na1-45e01c05-08b4-4232-9fc7-5e6660ef8511');
req.setHeader('Content-Type', 'application/json');

String requestBody = '{' +
    '"properties": {' +
        '"student_name": "Anisha Doe",' +
        '"email": "anisha@example.com"' +
    '}' +
'}';
req.setBody(requestBody);

Http http = new Http();
HTTPResponse res = http.send(req);

System.debug(res.getBody());
        
    }
}