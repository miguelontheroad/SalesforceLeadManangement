@isTest
public class CountryLayerHandlerTest {
    
    @testSetup
    static void setup() {
        Country__c country = new Country__c(Name = 'Australia',
                                            Capital__c = 'Canberra', 
                                            Alpha2Code__c = 'AU', 
                                            Alpha3Code__c = 'AUS', 
                                            Region__c = 'Oceania', 
                                            RegionalBlocs__c = 'APEC');
        insert country;
    }

    @isTest
    static void testCountryUpdate() {
        Test.setMock(HttpCalloutMock.class, new CountryLayerMockResponse());
        
        Test.startTest();
            CountryLayerHandler.updateCountryInformation();
        Test.stopTest();

        Country__c updatedCountry = [SELECT Capital__c FROM Country__c WHERE Name = 'Australia'];
        Assert.areEqual('Canberra', updatedCountry.Capital__c, 'The capital should be updated to Canberra.');
    }

    @isTest
    static void testCountryUpdateWithApiError() {
        Test.setMock(HttpCalloutMock.class, new CountryLayerMockErrorResponse(400));
        
        Test.startTest();
        
        try {
            CountryLayerHandler.updateCountryInformation();
        } catch (System.CalloutException e) {
            Assert.isTrue(e.getMessage().contains('400'), 'Error code should be in the exception message.');
        }
        
        Test.stopTest();
    }

    public class CountryLayerMockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"name":"Australia","capital":"Canberra","alpha2Code":"AU","alpha3Code":"AUS","region":"Oceania","regionalBlocs":[{"acronym":"ASEAN"}]}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class CountryLayerMockErrorResponse implements HttpCalloutMock {
        private Integer statusCode;

        public CountryLayerMockErrorResponse(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            String errorBody = '{"success": false, "error": {"code": 400, "type": "400_bad_request", "info": "Unhandled Error"}}';
            res.setBody(errorBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}