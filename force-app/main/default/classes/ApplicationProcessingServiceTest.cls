/*Test Class for ApplicationProcessingService class */
@isTest
public class ApplicationProcessingServiceTest {
    
    @testSetup
    static void setupData() {
        
        List<Account> listAccounts = new List<Account>();
        
        Account acc = new Account(Name = 'Existing Company',Federal_Tax_Id__c = 'BG123456789');
        
        Account accName = new Account(Name = 'Name Match Company');
        
        listAccounts.add(acc);
        listAccounts.add(accName);
        
        insert listAccounts;
        
    }
    
    
    @isTest
    static void testLeadCreation() {
        
        
        ApplicationDTO app = new ApplicationDTO();
        
        app.companyName = 'New Company';
        app.federalTaxId = 'NEW123';
        app.applicationSource = 'Community';
        
        
        ApplicationDTO.ContactDTO contact = new ApplicationDTO.ContactDTO();
        
        contact.firstName = 'John';
        contact.lastName = 'Smith';
        contact.email = 'john@test.com';
        contact.phone = '123456789';
        
        app.contact = contact;
        
        
        Test.startTest();
        
        ApplicationResult result =
            ApplicationProcessingService.processApplication(app);
        
        Test.stopTest();
        
        
        
        System.assertEquals(true, result.success);
        System.assertEquals('Lead', result.recordType);
        
        
        
        Lead createdLead = [
            SELECT Id,
                   Company,
                   Federal_Tax_Id__c,
                   Application_Source__c
            FROM Lead
            WHERE Id = :result.recordId limit 1
        ];
        
        
        System.assertEquals(
            'New Company',
        createdLead.Company
            );
        
        System.assertEquals(
            'Community',
        createdLead.Application_Source__c
            );
        
    }
    
    
    @isTest
    static void testOpportunityByTaxId() {
        
        
        ApplicationDTO app = new ApplicationDTO();
        app.companyName = 'Existing Company';
        app.federalTaxId = 'BG123456789';
        app.applicationSource = 'Community';
        
        
        
        Test.startTest();
        ApplicationResult result =
            ApplicationProcessingService.processApplication(app);
        
        Test.stopTest();
        
        System.assertEquals(true, result.success);    
        System.assertEquals('Opportunity',result.recordType);
        
        Opportunity opp = [
            SELECT Id,
                   AccountId,
                   Application_Source__c
            FROM Opportunity
            WHERE Id = :result.recordId limit 1
        ];
        
        
        
        System.assertEquals(
            'Community',
        opp.Application_Source__c
            );
        
        
    }
    
    
    @isTest
    static void testOpportunityByNameMatch() {
        
        
        ApplicationDTO app = new ApplicationDTO();
        
        app.companyName = 'Name Match Company';
        app.federalTaxId = null;
        app.applicationSource = 'Webhook';
        
        
        Test.startTest();
        
        ApplicationResult result =
            ApplicationProcessingService.processApplication(app);
        
        Test.stopTest();
        
        
        System.assertEquals(
            true,
        result.success
            );
        
        
        System.assertEquals(
            'Opportunity',
        result.recordType
            );
        
        
        
        Opportunity opp = [
            SELECT Id,
                   Application_Source__c
            FROM Opportunity
            WHERE Id = :result.recordId limit 1
        ];
        
        
        
        System.assertEquals(
            'Webhook',
        opp.Application_Source__c
            );
        
        
    }
    
    
    @isTest
    static void testApplicationSourceValues() {
        
        
        ApplicationDTO app = new ApplicationDTO();
        
        app.companyName = 'Webhook Company';
        app.federalTaxId = 'WEB123';
        app.applicationSource = 'Webhook';
        
        ApplicationDTO.ContactDTO contact = new ApplicationDTO.ContactDTO();
        
        contact.firstName = 'John';
        contact.lastName = 'Smith';
        contact.email = 'john@test.com';
        contact.phone = '123456789';
        
        app.contact = contact;
        
        
        
        Test.startTest();
        
        ApplicationResult result =
            ApplicationProcessingService.processApplication(app);
        
        Test.stopTest();
        
        
        
        Lead lead = [
            SELECT Application_Source__c
            FROM Lead
            WHERE Id = :result.recordId limit 1
        ];
        
        
        
        System.assertEquals(
            'Webhook',
        lead.Application_Source__c
            );
        
    }
    
    
}