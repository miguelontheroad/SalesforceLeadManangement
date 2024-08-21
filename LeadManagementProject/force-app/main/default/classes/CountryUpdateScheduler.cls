/**
 * @description       : Schedulable class for the Country information update
 * @author            : Miguel Garcia 
 * Modifications Log
 * 1.0   20.08.2024   Miguel Garcia                        Initial version.
**/
public class CountryUpdateScheduler implements Schedulable {
    /**
    * @description Execute method
    * @param sc
    **/
    public void execute(SchedulableContext sc) {
        CountryLayerHandler.updateCountryInformation();
    }
}