/**
 * @description       : Handler class for the Country information fetched from External API
 * @author            : Miguel Garcia 
 * Modifications Log
 * 1.0   19.08.2024   Miguel Garcia                        Initial version.
**/
public with sharing class CountryLayerHandler {
    private static final String ENDPOINT;
    private static final String API_KEY;

    static {
        APISetting__mdt settings = [SELECT Endpoint__c, Key__c FROM APISetting__mdt LIMIT 1];
        API_KEY = settings.Key__c;
        ENDPOINT = settings.Endpoint__c;
    }

    /**
    * @description Method to get country information by country name
    * @param countryName
    * @return Map<String, Object>
    **/
    public static Map<String, Object> getCountryDataByName(String countryName) {

        Map<String, Object> responseDataMap = new Map<String, Object>();
        String apiEndpoint = ENDPOINT 
        + 'name/' + EncodingUtil.urlEncode(countryName, 'UTF-8') 
        + '?access_key=' + API_KEY 
        + '&fullText=true';
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiEndpoint);
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            List<Object> responseData = (List<Object>) JSON.deserializeUntyped(res.getBody());
            if (responseData != null && !responseData.isEmpty()) {
                responseDataMap = (Map<String, Object>) responseData[0];
            }
        } else {
            throw new System.CalloutException('Error: ' + res.getBody());
        }

        return responseDataMap;
    }

    /**
    * @description Method to update country information on the ORG
    **/
    public static void updateCountryInformation() {
        List<Country__c> countriesToUpdate = new List<Country__c>();

        List<Country__c> countries = [SELECT Id, Name, Capital__c, Alpha2Code__c, Alpha3Code__c, Region__c, RegionalBlocs__c FROM Country__c];

        if (!countries.isEmpty()) {
            for (Country__c country : countries) {
                try {
                    Map<String, Object> countryData = getCountryDataByName(country.Name);

                    if (countryData != null) { 
                        country.Capital__c = countryData.get('capital').toString();
                        country.Alpha2Code__c = countryData.get('alpha2Code').toString();
                        country.Alpha3Code__c = countryData.get('alpha3Code').toString();
                        country.Region__c = countryData.get('region').toString();
                        
                        Object regionalBlocsObj = countryData.get('regionalBlocs');
                        if (regionalBlocsObj != null) {
                            List<Object> regionalBlocs = (List<Object>) regionalBlocsObj;
                            Map<String, Object> regionalBloc = (Map<String, Object>) regionalBlocs[0];

                            //Regional Blocs assignment should be changed to the Multipicklist
                            country.RegionalBlocs__c = isValidCountryRegionalBloc(regionalBloc.get('acronym').toString()) ? regionalBloc.get('acronym').toString() : null;
                        }
                        countriesToUpdate.add(country);
                    }
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, country.Name + ' - Exception: ' + e.getMessage());
                }
            }

            if (!countriesToUpdate.isEmpty()) {
                update countriesToUpdate;
            }
        }
    }

    /**
    * @description Method to validate regional bloc picklist value
    * @param regionalBloc
    **/
    private static Boolean isValidCountryRegionalBloc(String regionalBloc) {
        Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Country__c.fields.getMap().get('RegionalBlocs__c').getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getValue() == regionalBloc) {
                return true;
            }
        }
        return false;
    }

}