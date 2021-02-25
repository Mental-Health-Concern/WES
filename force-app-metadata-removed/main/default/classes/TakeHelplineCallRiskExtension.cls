public class TakeHelplineCallRiskExtension {
    
    public Appointment__c currentAppt;
    public Risk__c risk {get;set;}
    public Risk__c clRisk {get;set;}
    public Risk__c adRisk {get;set;}
    public Risk__c chRisk {get;set;}
    
    public TakeHelplineCallRiskExtension(ApexPages.StandardController stdController) {
        this.currentAppt = [SELECT ID, Name, Contact__c, Case__c, Account__c, Start_Date_Time__c, Duration__c FROM Appointment__c where ID = :stdController.getID()];
        this.risk = new Risk__c();
        this.clrisk = new Risk__c(Date_Raised__c = Date.today(), Contact__c = currentAppt.Contact__c, RecordTypeID = Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Clinical Risk').getRecordTypeID(), Appointment__c = currentAppt.Id, Case__c = currentAppt.Case__c, Account__c = currentAppt.Account__c);
        this.adrisk = new Risk__c(Date_Raised__c = Date.today(), Contact__c = currentAppt.Contact__c, RecordTypeID = Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Vulnerable Adults').getRecordTypeID(), Appointment__c = currentAppt.Id, Case__c = currentAppt.Case__c, Account__c = currentAppt.Account__c);
        this.chrisk = new Risk__c(Date_Raised__c = Date.today(), Contact__c = currentAppt.Contact__c, RecordTypeID = Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Child Protection').getRecordTypeID(), Appointment__c = currentAppt.Id, Case__c = currentAppt.Case__c, Account__c = currentAppt.Account__c);
    }
    
    public PageReference insertRiskUpdateAppt(){
        if(risk.RecordTypeID == Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Clinical Risk').getRecordTypeId()){
            try{
                insert clRisk;
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
            }
        }else if(risk.RecordTypeID == Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Vulnerable Adults').getRecordTypeId()){
            try{
                insert adrisk;
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
            }
            
        }else if(risk.RecordTypeID == Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Child Protection').getRecordTypeId()){
            try{
                insert chrisk;
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, ex.getMessage()));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'You must select a Risk Type!'));
        }
        try{
            Long startDate = currentAppt.Start_Date_Time__c.getTime();
            Long timeNow = DateTime.now().getTime();
            Long minutesBetween = (timeNow - startDate) / 60000;
            minutesBetween = minutesBetween + 3;
            currentAppt.Duration__c = minutesBetween.format();
            currentAppt.Outcome__c = 'Attended on time';
            update currentAppt;
            PageReference retURL = new PageReference('/apex/VerifyAppointmentTime?id=' + currentAppt.Id);
            retURL.setRedirect(true);
              return retURL;
            }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error completing appointment: ' + ex.GetMessage()));
        }
        return null;
        
    }
    
    public List<SelectOption> getRecordTypePicklist(){
        List<SelectOption> selectOptions = new List<SelectOption>();
        selectOptions.add(new SelectOption('-- No Risk Type Selected --', '-- No Risk Type Selected --'));
        selectOptions.add(new SelectOption(Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Clinical Risk').getRecordTypeId(), 'Clinical Risk' ));
        selectOptions.add(new SelectOption(Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Child Protection').getRecordTypeId(), 'Child Protection'));
        selectOptions.add(new SelectOption(Schema.SObjectType.Risk__c.getRecordTypeInfosByName().get('Vulnerable Adults').getRecordTypeId(), 'Vulnerable Adults'));
        return selectOptions;
    } 

}