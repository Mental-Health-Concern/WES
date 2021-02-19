public class AuthorisationClass {

    private static List<Authorisation__c> toAddError(List<Authorisation__c> approvals){
        Set<Id> caseIds = new Set<Id>();
        
        for(Authorisation__c a : approvals){
            if(a.isOpen__c){
                
                caseIds.add(a.Case__c);
            }
            
        }
        List<Authorisation__c> apps = [SELECT Id, Case__c FROM Authorisation__c WHERE Case__c IN :caseIds AND isOpen__c = true];
        Set<Id> appIds = new Set<Id>();
        for(Authorisation__c a : apps){
            appIds.add(a.Id);
        }
        
        List<Authorisation__c> toReturn = new List<Authorisation__c>();
        for(Authorisation__c a : approvals){
            
            for(Authorisation__c a2 : apps){
                if((a2.Id != a.Id) && (a2.case__c == a.Case__c)){
                    toReturn.add(a);
                }
            }
            
        }
        return toReturn;
        
    }

    public static void addErrors(List<Authorisation__c> approvals){
        for(Authorisation__c a : toAddError(approvals)){
            a.addError('There is already an open approval request against this case!');
        }
    }
    

}