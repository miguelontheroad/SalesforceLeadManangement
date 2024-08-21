/**
 * @description       : Trigger Handler for Lead Object
 * @author            : Miguel Garcia 
 * Modifications Log
 * 1.0   21.08.2024   Miguel Garcia                        Initial version.
**/
public class LeadTriggerHandler {

    public void beforeInsertUpdate(List<Lead> newLeads) {
        Set<String> countries = new Set<String>();
    
        for (Lead lead : newLeads) {
            if (String.isNotBlank(lead.Country)) {
                countries.add(lead.Country);
            }
        }
        Map<String, Country__c> countryMap = new Map<String, Country__c>(
            [SELECT Name, Region__c, Alpha3Code__c, Capital__c 
             FROM Country__c 
             WHERE Name IN :countries]
        );
        
        for (Lead lead : newLeads) {
            if (countryMap.containsKey(lead.Country)) {
                Country__c countryInfo = countryMap.get(lead.Country);
                lead.CountryRegion__c = countryInfo.Region__c;
                lead.CountryCode__c = countryInfo.Alpha3Code__c;
                lead.CountryCapital__c = countryInfo.Capital__c;
            } else {
                if (String.isNotBlank(lead.Country)){
                    try {
                        //Call the API to retrieve the releted info
                        Map<String, Object> countryData = CountryLayerHandler.getCountryDataByName(lead.Country);

                        if (countryData != null) { 
                            lead.CountryCapital__c = countryData.get('capital').toString();
                            lead.CountryCode__c = countryData.get('alpha3Code').toString();
                            lead.CountryRegion__c = countryData.get('region').toString();
                        }
                    } catch (Exception exc) {
                        System.debug(LoggingLevel.ERROR, lead.Country + ' - Exception: ' + exc.getMessage());
                    } 
                }
            }
        }
    }
}