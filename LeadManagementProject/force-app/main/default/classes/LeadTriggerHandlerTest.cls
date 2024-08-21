@isTest
public class LeadTriggerHandlerTest { 

    @isTest
    static void testBeforeInsertUpdate() {
        Country__c testCountry = new Country__c(
            Name = 'TestCountry',
            Region__c = 'TestRegion',
            Alpha3Code__c = 'TST',
            Capital__c = 'TestCapital'
        );
        insert testCountry;

        Lead testLeadValid = new Lead(
            FirstName = 'John',
            LastName = 'Donut',
            Country = 'TestCountry',
            Company = 'John Donut'
        );

        Lead testLeadInvalid = new Lead(
            FirstName = 'Scarlet',
            LastName = 'Switch',
            Country = 'InvalidCountry',
            Company = 'Scarlet Switch'
        );

        List<Lead> testLeads = new List<Lead>{ testLeadValid, testLeadInvalid };

        Test.startTest();
            insert testLeads;
        Test.stopTest();

        testLeadValid = [SELECT CountryRegion__c, CountryCode__c, CountryCapital__c FROM Lead WHERE Id = :testLeadValid.Id];
        testLeadInvalid = [SELECT CountryRegion__c, CountryCode__c, CountryCapital__c FROM Lead WHERE Id = :testLeadInvalid.Id];

        Assert.areEqual(null, testLeadInvalid.CountryRegion__c);
        Assert.areEqual(null, testLeadInvalid.CountryCode__c);
        Assert.areEqual(null, testLeadInvalid.CountryCapital__c);
    }
}