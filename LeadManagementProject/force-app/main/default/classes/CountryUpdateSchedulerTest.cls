/**
 * @description       : Test for Schedulable class
 * @author            : Miguel Garcia 
 * Modifications Log
 * 1.0   20.08.2024   Miguel Garcia                        Initial version.
**/
@isTest
public with sharing class CountryUpdateSchedulerTest {

    @isTest
    static void testCountryUpdateScheduler() {
        Test.startTest();
            CountryUpdateScheduler countryUpdateScheduler = new CountryUpdateScheduler();
            countryUpdateScheduler.execute(null);
        Test.stopTest();

        Assert.areNotEqual(null, countryUpdateScheduler, 'CountryUpdateScheduler shouldn\'t be null');
    }
}