/**
 * @File Name          : CaseClass.cls
 * @Description        : 
 * @Author             : Brodie Lawton
 * @Group              : 
 * @Last Modified By   : Brodie Lawton
 * @Last Modified On   : 4/26/2020, 5:21:46 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/26/2020   Brodie Lawton     Initial Version
**/
public class CaseClass {
    
    
    public void beforeUpdate(List<Case> cases){
        checkRiskOnCaseClosure(cases);
        checkApptOutcomeOnClosure(cases);
        
    }
    
    public void afterUpdate(List<Case> cases){
        
    }
    
    private void checkRiskOnCaseClosure(List<Case> cases){
        Set<Id> caseIDs = new Set<Id>();
        
        for(Case c: cases){
            if(c.Status == 'Discharged' || c.Status == 'Closed Awaiting Admin'){
                caseIds.add(c.id);
            }
            
        }
        
        List<Risk__c> risks = [SELECT ID, Case__c, Case__r.CaseNumber FROM Risk__c WHERE Case__c in :caseIds AND Manager_Sign_Off_at_EOC_Closure__c = ''];
        
        if(risks.size() > 0){
            for(Case c : cases){
                c.addError('These case(s) cannot be closed as there is outstanding risk');
            }
            
        }
        
        
        
    }
    
    private void checkApptOutcomeOnClosure(List<Case> cases){
        Set<Id> caseIds = new Set<Id>();
        
        for(Case c : cases ){
            if(c.Status == 'Discharged' || c.Status == 'Closed Awaiting Admin'){
                caseIds.add(c.id);
            }
            
        }
        List<Appointment__c> appts = [SELECT ID From Appointment__c WHERE Case__c IN :caseIds AND Outcome__c = ''];
        if(appts.size() > 0){
            for(Case c : cases){
                c.addError('These case(s) cannot be closed as there are appointments without an outcome');
            }
            
        }
        
        
        
        
    }
}