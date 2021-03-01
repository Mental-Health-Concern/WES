/**
* @File Name          : QuestionnaireClass.cls
* @Description        : 
* @Author             : Brodie Lawton
* @Group              : 
* @Last Modified By   : Brodie Lawton
* @Last Modified On   : 07-15-2020
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    4/19/2020   Brodie Lawton     Initial Version
**/
public class QuestionnaireClass {
    
    public static void addCaseAndAccount(Map<Id, Questionnaire__c> oldQuestMap, List<Questionnaire__c> newQuests){
        for(Questionnaire__c q : newQuests){
            if(q.Appointment__c != oldQuestMap.get(q.Id).Appointment__c){
                q.Case__c = q.AppointmentCaseId__c;
                q.Account__c = q.AppointmentAccountId__c;
                q.Contact__C = q.AppointmentContactId__c;
            }
        }
    }

    public static void addCaseAndAccount(List<Questionnaire__c> newQuests){
        for(Questionnaire__c q : newQuests){
            q.Case__c = q.AppointmentCaseId__c;
            q.Account__c = q.AppointmentAccountId__c;
            q.Contact__C = q.AppointmentContactId__c;
        }
    }

    public static List<Case> rollupScores(List<Questionnaire__c> quests){
        
        Set<Id> caseIds = new set<Id>(); // variable to collect case
        List<Case> casesToIterate = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        if(quests.size() > 0){
            for(Questionnaire__c q : quests){
                if(!q.IsDeleted){
                    caseIds.add(q.AppointmentCaseId__c);
                    casesToIterate.add(new Case(id = q.AppointmentCaseId__c));
                }
                
            }
        }
        
        
        Map<Id, List<Questionnaire__c>> questMap = getQuestMap(caseIds);
        for(Case c : casesToIterate){
            
            
            Case combined = new Case(id = c.Id);
            Case gad = rollupGAD(questMap.get(c.Id));
            Case phq = rollupPHQ(questMap.get(c.Id));
            Case core = rollupCORE(QuestMap.get(c.Id));
            
            
            if(core != null){
                combined.First_Core10_Score__c = core.First_Core10_Score__c;
                combined.Last_Core10_Score__c = core.Last_Core10_Score__c;
            }
            if(gad != null){
                combined.First_GAD7_Score__c = gad.First_GAD7_Score__c;
                combined.Last_GAD7_Score__c = gad.Last_GAD7_Score__c;
            }
            if(phq != null){
                combined.First_PHQ9_Score__c = phq.First_PHQ9_Score__c;
                combined.Last_PHQ9_Score__c = phq.Last_PHQ9_Score__c;
            }
            
            casesToUpdate.add(combined);
            
            
            
            
        }
        
        return casesToUpdate;
    }
    
    private static Map<Id, List<Questionnaire__c>> getQuestMap(Set<Id> caseIds){
        if(caseIds.size() > 0){ // ensures blank lists are not processed
            Map<Id, List<Questionnaire__c>> questMap = new Map<Id, List<Questionnaire__c>>();
            List<Questionnaire__c> quests = new List<Questionnaire__c>(); // list for query to save records
            for(Questionnaire__c q : [SELECT ID, RecordType.Name, AppointmentCaseId__c, Total_Score__c  FROM Questionnaire__c WHERE AppointmentCaseId__c IN :caseIds AND Questionnaire_Declined__c = false ORDER BY Appointment_Start_Date_Time__c asc]){
                quests.add(q); // adds current record to quests list
            }
            for(Id cId : caseIds){
                List<Questionnaire__c> questsOnCase = new List<Questionnaire__c>();
                for(Questionnaire__c q : quests){
                    if(q.AppointmentCaseId__c == cId){
                        questsOnCase.add(q);
                    }
                }
                questMap.put(cId, questsOnCase);
            }
            return questMap;
        }else{
            return null;
        }
        
        
    }
    
    private static Case rollupGAD(List<Questionnaire__c> quests){
        if(quests.size() > 0){
            List<Questionnaire__c> gads = new List<Questionnaire__c>();
            for(Questionnaire__c q : quests){
                if(Schema.getGlobalDescribe().get('Questionnaire__c').getDescribe().getRecordTypeInfosById().get(q.RecordTypeId).getName() == 'GAD7'){
                    gads.add(q);
                }
            }
            Case toReturn = new Case();
            if(gads.size() > 0 ){
                toReturn = new Case(id = gads[0].AppointmentCaseId__c, First_GAD7_Score__c = gads[0].Total_Score__c, Last_GAD7_Score__c = gads[gads.size() - 1].Total_Score__c);
            }else{
                toReturn = new Case(id = quests[0].AppointmentCaseId__c, First_GAD7_Score__c = null, Last_GAD7_Score__c = null);
            }
            return toReturn;
        }
        else{
            return null;
        }
        
    }
    
    private static Case rollupCORE(List<Questionnaire__c> quests){
        if(quests.size() > 0){ // ensures blank lists are not processed
            List<Questionnaire__c> cores = new List<Questionnaire__c>();
            for(Questionnaire__c q : quests){
                if(Schema.getGlobalDescribe().get('Questionnaire__c').getDescribe().getRecordTypeInfosById().get(q.RecordTypeId).getName() == 'CORE10'){
                    cores.add(q);
                }
            }
            
            Case toReturn = new Case();
            if(cores.size() > 0){
                toReturn = new Case(id = cores[0].AppointmentCaseId__c, First_CORE10_Score__c = cores[0].Total_Score__c, Last_CORE10_Score__c = cores[cores.size() - 1].Total_Score__c);
            }else{
                toReturn = new Case(id = quests[0].AppointmentCaseId__c, First_CORE10_Score__c = null, Last_CORE10_Score__c = null);
            }
            return toReturn;
        }else{
            system.debug('ERROR ON ROLLUP. NO CORE FOUND');
            return null;
        }
    }
    
    private static Case rollupPHQ(List<Questionnaire__c> quests){
        
        if(quests.size() > 0){
            List<Questionnaire__c> phqs = new List<Questionnaire__c>();
            for(Questionnaire__c q : quests){
                if(Schema.getGlobalDescribe().get('Questionnaire__c').getDescribe().getRecordTypeInfosById().get(q.RecordTypeId).getName() == 'PHQ9'){
                    phqs.add(q);
                }
            }
            system.debug('phqs: ' + phqs);
            
            Case toReturn = new Case();
            system.debug(phqs);
            system.debug(quests);
            if(phqs.size() > 0){
                toReturn = new Case(id = phqs[0].AppointmentCaseId__c, First_PHQ9_Score__c = phqs[0].Total_Score__c, Last_PHQ9_Score__c = phqs[phqs.size() - 1].Total_Score__c);
            }else{
                toReturn = new Case(id = quests[0].AppointmentCaseId__c, First_PHQ9_Score__c = null, Last_PHQ9_Score__c = null);
            }
            return toReturn;
        }else{
            system.debug('ERROR ON ROLLUP. NO PHQ FOUND');
            return null;
            
        }
    }
    
    
}