public class authorisationPageExtension {
    
    private final Case currentCase;
    public Account caseAccount {get;set;}
    public Authorisation__c authRecord{get;set;}
    public Authorisation__c authCancel{get;set;}
    public List<String> therapyTypes{get;set;}
    public String typeForInsert{get;set;}
    
    
    public authorisationPageExtension(ApexPages.StandardController controller) {
        this.currentCase = [SELECT ID, Referral_Date__c, CaseNumber, Contact.Name, WAW_External_Referrer_Contact__c, AccountId, WAW_Assessment_Recomendation__c FROM Case WHERE Id = :controller.getId()];
        this.caseAccount = [SELECT ID, OwnerId, WAW_Authorisation_Contact__C, WAW_Portal_Authorisation__c FROM Account WHERE ID = :currentCase.AccountId];
        this.authRecord = new Authorisation__c(Type__c = currentCase.WAW_Assessment_Recomendation__c, Status__c = 'Submitted', Case__c = currentCase.Id, Contract_Manager__c = caseAccount.OwnerId);
        this.authCancel = new Authorisation__c();
        if(currentCase.WAW_External_Referrer_Contact__c != null){
            this.authRecord.Authorisation_Contact__c = currentCase.WAW_External_Referrer_Contact__c;
            
        }else if(caseAccount.WAW_Authorisation_Contact__C != null){
            this.authRecord.Authorisation_Contact__c = caseAccount.WAW_Authorisation_Contact__c;
        }
        else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is no external referrer on this case or on the account. You cannot seek approval without an external approver! Please contact the Service or Administration manager'));
        }
    }
    
    public List<SelectOption> getTypePicklist(){
        List<Charge__c> chargesReqAuthorisation = [SELECT Id, Type__c FROM Charge__c WHERE Additional_Appointment_Authorisation__c = 'Yes' AND Start_Date__c <= :currentCase.Referral_Date__c AND End_Date__c >= :currentCase.Referral_Date__c];
        List<SelectOption> selectOptions = new List<SelectOption>();
        List<String> types = new List<String>();
        
        for(charge__c c : chargesReqAuthorisation){
            types.add(c.Type__c);
        }
        
        if(currentCase.WAW_Assessment_Recomendation__c != null && types.contains(currentCase.WAW_Assessment_Recomendation__c)){
            selectOptions.add(new SelectOption(currentCase.WAW_Assessment_Recomendation__c , currentCase.WAW_Assessment_Recomendation__c));
        }
        for(Charge__c c : chargesReqAuthorisation){
            if(c.Type__c != currentCase.WAW_Assessment_Recomendation__c){
                selectOptions.add(new SelectOption(c.Type__c, c.Type__c));
            }
            
        }
        return selectOptions;
    }   
    
    public Integer getNumOfOpenRequests(){
        return [SELECT Id FROM Authorisation__c WHERE Case__c = :currentCase.Id AND (Status__c = 'Submitted' OR Status__c = 'Initial Approval - Service Manager')].size();
    }
    
    public PageReference insertAuth(){
      
            Id approverUserId = null;
            try{
                approverUserId = [SELECT Id FROM User WHERE ContactID = :authRecord.Authorisation_Contact__c].Id;
            }catch(Exception ex){
                approverUserId = null;
            }
            if(approverUserID != null){
                try{
                    authRecord.Id = null;
                    authRecord.Contract_Approver_User__c = approverUserId;
                    authRecord.Date_Time_Opened__c = DateTime.now();
                    insert authRecord;
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'An authorisation request has been submitted for Case: ' + currentCase.CaseNumber));
                    return new PageReference('/' + authRecord.Id);
                }catch(Exception ex){
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                    return null;
                }
            }else{
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The approver associated with this client is not a portal user! Contract approvers need to be registered as portal users before they can approve using the portal!'));
                return null;
            }
            
    }
    
    public void cancelApprovalRequest(){
        try{
            Authorisation__c auth = getAuthorisation();
            
            auth.Date_Time_Cancelled__c = DateTime.now();
            auth.Date_Time_Closed__c = DateTime.now();
            auth.Cancellation_Reason__c = authCancel.Cancellation_Reason__c;
            auth.Status__c = 'Cancelled';
            update auth;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Request ' + auth.Name + ' has been successfully cancelled'));
        }catch(Exception ex){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    public Authorisation__c getAuthorisation(){
        Authorisation__c auth = [SELECT ID, Name, Cancellation_Reason__c, Type__c, Contract_Manager__c, Supporting_Comments__c, Status__c, Case__c, Authorisation_Contact__c, Authorisation_Contact__r.Name, Date_Time_Opened__c, Date_Time_Closed__c FROM Authorisation__c where isOpen__c = true and Case__c = :currentCase.Id LIMIT 1];
        if(auth.id != null){
            return auth;
        }
        else{
            return null;
        }
    }

}