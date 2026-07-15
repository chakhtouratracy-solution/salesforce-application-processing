/* Class: ApplicationDTO
Description:  Wrapper class used to represent an external application submission.
     * This wrapper standardizes the application data structure shared between the Experience Cloud LWC,
 * and the REST webhook.
 * It contains company information, contact details, revenue information, and the source of the application.
 */
public class ApplicationDTO {
    
    @AuraEnabled
    public String companyName;
    @AuraEnabled
    public String federalTaxId;
    @AuraEnabled
    public ContactDTO contact;
    @AuraEnabled
    public Decimal annualRevenue;
    @AuraEnabled
    public String applicationSource;
    
    public class ContactDTO {

        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String phone;
    }
}