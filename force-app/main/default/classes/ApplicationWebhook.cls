/* Class: ApplicationWebhook
 * Description: REST endpoint used by external systems to submit applications.
 */
@RestResource(urlMapping='/external/applications')
global with sharing class ApplicationWebhook {
    
    @HttpPost
    global static ApplicationResult handlePost() {
        
        ApplicationResult result = new ApplicationResult();
        
        try {
            
            RestRequest request = RestContext.request;
            
            String requestBody = request.requestBody.toString();
            
            ApplicationDTO application =
                (ApplicationDTO) JSON.deserialize(requestBody, ApplicationDTO.class);
            
            application.applicationSource = 'Webhook';
            
            result = ApplicationProcessingService.processApplication(application);
            
        } catch (Exception e) {
            
            result.success = false;
            result.message = e.getMessage();
            
        }
        
        return result;
    }
}