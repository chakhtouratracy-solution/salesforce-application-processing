/* Class: ApplicationProcessingService
 * Description: Service class responsible for processing external applications.
 * Determines whether to create a Lead or Opportunity based on Account matching rules.
 */

public with sharing class ApplicationProcessingService {
    
    public static ApplicationResult processApplication(ApplicationDTO app) {
        
        ApplicationResult result = new ApplicationResult();
        
        try {
            
            if (app == null) {
                throw new IllegalArgumentException('Application cannot be null');
            }
            
            Account matchedAccount;
            String searchField;
            String searchValue;
            
            if (String.isNotBlank(app.federalTaxId)) {
                searchField = 'Federal_Tax_Id__c';
                searchValue = app.federalTaxId;
            } else if (String.isNotBlank(app.companyName)) {
                searchField = 'Name';
                searchValue = app.companyName;
            }
            
            if (searchValue != null) {
                String query = 'SELECT Id, Name FROM Account WHERE '
                    + searchField
                    + ' = :searchValue LIMIT 1';
                
                List<Account> accounts = Database.query(query);
                
                if (!accounts.isEmpty()) {
                    matchedAccount = accounts[0];
                }
            }
            
            if (matchedAccount != null) {
                
                Opportunity opp = new Opportunity();
                opp.Name = app.companyName + ' - New Application';
                opp.StageName = System.Label.OpportunityStage;
                opp.CloseDate = Date.today().addDays(30);
                opp.AccountId = matchedAccount.Id;
                opp.Application_Source__c = app.applicationSource;
                
                insert opp;
                
                result = createSuccessResult(
                    'Opportunity',
                opp.Id
                    );
                
            } else {
                
                Lead lead = new Lead();
                if(app.contact!=null){
                    lead.FirstName = app.contact.firstName;
                    lead.LastName = app.contact.lastName;
                    lead.Email = app.contact.email;
                    lead.Phone = app.contact.phone;
                }
                lead.Company = app.companyName;
                lead.Federal_Tax_Id__c = app.federalTaxId;
                lead.Application_Source__c = app.applicationSource;
                lead.AnnualRevenue  = app.annualRevenue;
                
                insert lead;
                
                result = createSuccessResult(
                    'Lead',
                lead.Id
                    );
            }
            
        } catch (Exception e) {
            
            result.success = false;
            result.message = e.getMessage();
            
        }
        
        return result;
    }
    
    
    private static ApplicationResult createSuccessResult(String recordType, Id recordId) {
        
        ApplicationResult result = new ApplicationResult();
        result.success = true;
        result.recordType = recordType;
        result.recordId = recordId;
        result.message = 'Application processed successfully';
        
        return result;
    }
}