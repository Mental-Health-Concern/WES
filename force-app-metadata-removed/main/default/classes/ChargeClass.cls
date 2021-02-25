public class ChargeClass {
    public static boolean checkExistingCharges(Charge__c charge, boolean isInsert){
        
        List<Charge__c> charges = [SELECT Id, Start_Date__c, End_Date__c FROM Charge__c WHERE Type__c = :charge.Type__c AND Account__c = :charge.Account__c];
        List<Charge__c> overlapping = new List<Charge__c>();
        
        for(Charge__c c : charges){
            if(((charge.Start_Date__c >= c.Start_Date__c && charge.Start_Date__c < c.End_Date__c) || (charge.End_Date__c > c.Start_Date__c && charge.End_Date__c <= c.End_Date__c))){
                overlapping.add(c);
            }
        }
        
        if(overlapping.size() > 0 && isInsert == true){
            return true;
        }else if(overlapping.size() > 1 && isInsert == false){
            return true;
        }else{
            return false;
        }
    }
    
    
    
}