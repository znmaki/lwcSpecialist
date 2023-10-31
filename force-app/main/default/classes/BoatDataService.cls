public with sharing class BoatDataService {
    public static final String LENGTH_TYPE = 'Length'; 
    public static final String PRICE_TYPE = 'Price'; 
    public static final String TYPE_TYPE = 'Type'; 

    @AuraEnabled(cacheable=true)
    public static List<Boat__c> getBoats(string boatTypeId) {
        return [SELECT name, BoatType__c 
                FROM Boat__c 
                WHERE BoatType__c = :boatTypeId];
    }

    @AuraEnabled(cacheable=true)
    public static List<BoatType__c> getBoatTypes() {
        return [SELECT Id, Name 
                FROM BoatType__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<Boat__c> getSimilarBoats(Id boatId, String similarBy) {
        List<Boat__c> similarBoats = new List<Boat__c>();
        List<Boat__c> parentBoat = [SELECT Id, Length__c, Price__c, BoatType__c, BoatType__r.Name
                                    FROM Boat__c
                                    WHERE Id = :boatId 
                                    WITH SECURITY_ENFORCED];
        if (parentBoat.isEmpty()) {
            return similarBoats;
        }
        if (similarBy == LENGTH_TYPE) {
            similarBoats = [
                SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Picture__c, Price__c, Year_Built__c
                FROM Boat__c
                WHERE Id != :parentBoat.get(0).Id
                AND (Length__c >= :parentBoat.get(0).Length__c / 1.2)
                AND (Length__c <= :parentBoat.get(0).Length__c * 1.2)
                WITH SECURITY_ENFORCED
                ORDER BY Length__c, Price__c, Year_Built__c
            ];
        } else if (similarBy == PRICE_TYPE) {
            similarBoats = [
                SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Picture__c, Price__c, Year_Built__c
                FROM Boat__c
                WHERE Id != :parentBoat.get(0).Id
                AND (Price__c >= :parentBoat.get(0).Price__c / 1.2)
                AND (Price__c <= :parentBoat.get(0).Price__c * 1.2)
                WITH SECURITY_ENFORCED
                ORDER BY Price__c, Length__c, Year_Built__c
            ];
        } else if (similarBy == TYPE_TYPE) {
            similarBoats = [
                SELECT Id, Contact__r.Name, Name, BoatType__c, BoatType__r.Name, Length__c, Picture__c, Price__c, Year_Built__c
                FROM Boat__c
                WHERE Id != :parentBoat.get(0).Id
                AND (BoatType__c = :parentBoat.get(0).BoatType__c)
                WITH SECURITY_ENFORCED
                ORDER BY Price__c, Length__c, Year_Built__c
            ];
        }
        return similarBoats;
    }

    @AuraEnabled
    public static List<BoatReview__c> getAllReviews(Id boatId) {
        return [SELECT Id, Name, Comment__c, Rating__c, LastModifiedDate, CreatedDate, CreatedBy.Name, CreatedBy.SmallPhotoUrl, CreatedBy.CompanyName 
                FROM BoatReview__c 
                WHERE Boat__c = :boatId];
    }

    @AuraEnabled(cacheable=true)
    public static String getBoatsByLocation(Decimal latitude, Decimal longitude, String boatTypeId){
        List<Boat__c> boats = [SELECT Name, Geolocation__Latitude__s, Geolocation__Longitude__s, BoatType__c
                           FROM Boat__c
                           WHERE Geolocation__Latitude__s = :latitude AND Geolocation__Longitude__s = :longitude AND BoatType__c = :boatTypeId];
               
        String jsonResult = JSON.serialize(boats);
        
        return jsonResult;
    }
}
