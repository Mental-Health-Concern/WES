/**
 * @description       : 
 * @author            : Brodie Lawton
 * @group             : 
 * @last modified on  : 07-16-2020
 * @last modified by  : Brodie Lawton
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   07-13-2020   Brodie Lawton   Initial Version
**/
public class TakeHelplineCallExtension {
    public final Case currentCase;
    public Appointment__c appt {get;set;}
    public Questionnaire__c phq {get;set;}
    public Questionnaire__c gad {get;set;}
    public Questionnaire__c core {get;set;}
    public boolean requiredGAD {get;set;}
    public boolean requiredPHQ {get;set;}
    public boolean requiredCORE {get;set;}
    private boolean isRisk = false;
    private ApexPages.StandardController stdController;
    
    public TakeHelplineCallExtension(ApexPages.StandardController stdController){
        this.currentCase = [SELECT ID, CaseNumber, Referral_Date__c, Account.GAD_7__c, Account.PHQ_9__c, Account.Core10__c FROM Case WHERE ID = :stdController.getId()];
        this.requiredGAD = currentCase.Account.GAD_7__c;
        this.requiredPHQ = currentCase.Account.PHQ_9__c;
        this.requiredCORE = currentCase.Account.CORE10__c;
        Appointment__c appt = new Appointment__c(Case__c = this.currentCase.Id, Start_Date_Time__c = DateTime.now() - (1/1440), Practitioner__c = UserInfo.getUserId(), Type__c = 'Helpline Call', Duration__c = '1', No_Template__c = true);
        appt.Appointment_Notes__c = AppointmentTemplates.assessmentTemplate();

        this.appt = appt;
        
        this.phq = new Questionnaire__c(WAW_Complete_Questionnaire__c = this.requiredPHQ, RecordTypeId = Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get('PHQ9').getRecordTypeId());
        this.gad = new Questionnaire__c(WAW_Complete_Questionnaire__c = this.requiredGAD, RecordTypeId = Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get('GAD7').getRecordTypeId());
        this.core = new Questionnaire__c(WAW_Complete_Questionnaire__c = this.requiredCORE, RecordTypeId = Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get('CORE10').getRecordTypeId());
        this.stdController = stdController;
    }
    
    
    
    public List<SelectOption> getTypePicklist(){
        List<Charge__c> charges = [SELECT Id, Type__c FROM Charge__c WHERE Type__C != 'Helpline Call' AND isActive__c = true AND Account__c = :currentCase.AccountId];
        List<SelectOption> selectOptions = new List<SelectOption>();
        List<String> types = new List<String>();
        
        selectOptions.add(new SelectOption('No Further Treatment Recommended', 'No Further Treatment Recommended'));
        
        for(Charge__c c : charges){
            selectOptions.add(new SelectOption(c.Type__c, c.Type__c)); 
        }
        return selectOptions;
    }   
    
    public PageReference riskTypeInsertAppt(){
        boolean stopInserts = false;
        
        try{
            appt.Id = null;
            insert appt;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.GetMessage()));
            stopInserts = true;
        }
        try{
            if(stopInserts != true){
                if(gad.WAW_Complete_Questionnaire__c == true){
                    gad.Appointment__c = appt.Id;
                    insert gad;
                }
                
                if(phq.WAW_Complete_Questionnaire__c == true){
                    phq.Appointment__c = appt.Id;
                    insert phq;
                }
                
                if(core.WAW_Complete_Questionnaire__c == true){
                    core.Appointment__c = appt.Id;
                    insert core;
                }
            }
            
            
            
        } catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating Questionnaires: ' + ex.GetMessage()));
            stopInserts = true;
        }
        
        try{
            if(stopInserts != true){
                Long startDate = appt.Start_Date_Time__c.getTime();
                Long timeNow = DateTime.now().getTime();
                
                Long minutesBetween = (timeNow - startDate) / 60000;
                minutesBetween = minutesBetween + 3;
                appt.Duration__c = minutesBetween.format();
                
                
                
                update appt;
                
                
              
                PageReference retURL = new PageReference('/apex/TakeHelplineCallRisk?id=' + appt.Id);
                retURL.setRedirect(true);
                return retURL;
                
                
                
            } 
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error completing appointment: ' + ex.GetMessage()));
        }
        return null;
    }   
    
    public PageReference insertRecords(){
      
        boolean stopInserts = false;
        
        try{
            appt.Id = null;
            insert appt;
        }catch(Exception ex){
            stopInserts = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.GetMessage()));
           
        }
        try{
            if(stopInserts != true){
                if(gad.WAW_Complete_Questionnaire__c == true){
                    gad.Appointment__c = appt.Id;
                    try{
                        insert gad;
                    }catch(Exception ex){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving GAD7 Questionnaire: ' + ex.getMessage()));
                        delete appt;
                    }
                    
                }
                
                if(phq.WAW_Complete_Questionnaire__c == true){
                    phq.Appointment__c = appt.Id;
                    try{
                        insert phq;
                    }catch(Exception ex){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving PHQ9 Questionnaire: ' + ex.getMessage()));
                        delete appt;
                    }
                }
                
                if(core.WAW_Complete_Questionnaire__c == true){
                    core.Appointment__c = appt.Id;
                    try{
                        insert core;
                    }catch(Exception ex){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving CORE10 Questionnaire: ' + ex.getMessage()));
                        delete appt;
                    }
                }
            }
            
            
            
        }catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating Questionnaires: ' + ex.GetMessage()));
            stopInserts = true;
        }
        
        try{
            if(stopInserts != true){
                Long startDate = appt.Start_Date_Time__c.getTime();
                Long timeNow = DateTime.now().getTime();
                
                Long minutesBetween = (timeNow - startDate) / 60000;
                minutesBetween = minutesBetween + 3;
                appt.Duration__c = minutesBetween.format();
                
                appt.Outcome__c = 'Attended on time';
                
                update appt;
                
                
                isRisk = false;
                PageReference retURL = new PageReference('/apex/VerifyAppointmentTime?id=' + appt.Id);
                retURL.setRedirect(true);
                return retURL;
                
                
                
            } 
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error completing appointment: ' + ex.GetMessage()));
        }
        return null;
        
        
    }
    
    
}