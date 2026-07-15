/* Class: ApplicationFormController
 * Description: Controller used by the Experience Cloud application form.
 */
public with sharing class ApplicationFormController {
@AuraEnabled
public static ApplicationResult submitApplication(String input) {

    ApplicationDTO appDTO = (ApplicationDTO)JSON.deserialize(input, ApplicationDTO.class);
    appDTO.applicationSource = 'Community';
    
    return ApplicationProcessingService.processApplication(appDTO);
}
}