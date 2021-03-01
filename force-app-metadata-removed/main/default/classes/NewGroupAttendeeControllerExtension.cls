public with sharing class NewGroupAttendeeControllerExtension {
    
    private final Id groupId;
    private final Group_Appointment__c currentGroup;
    public List<Case> toSelect {get; set;}
    public List<Appointment__c> existingAppts {get; set;}
    public integer numOfAppts {get;set;}
    public string nameSearchText {get; set;}
    public boolean renderSearchTable {get; set;}
    public id AccountID{get;set;}
    
    public List<Appointment__c> getExisting(){
        return [SELECT Id, Name, Contact__c, Duration__c, Outcome__c, Type__c, Practitioner__c, Start_Date_Time__c, Case__c, Case__r.CaseNumber, Contact__r.Name, Contact__r.Birthdate, Account__r.Name FROM Appointment__c 
                              WHERE Group_Appointment__c = :this.currentGroup.Id AND (Outcome__c = 'Attended on time' OR Outcome__c = 'Arrived late and seen' OR Outcome__c = '')];
    }
    
    public String getStartDateTime(){
        return currentGroup.Start_Date_Time__c.format();
    }
    
    public String getEndDateTime(){
        return currentGroup.End_Date_Time__c.format();
    }
    
    
    public NewGroupAttendeeControllerExtension(ApexPages.StandardController stdController){
        this.groupId = stdController.getId();
        this.currentGroup = [SELECT Id, Name, Start_Date_Time__c, End_date_Time__c, Duration__c, Practitioner__c, Venue__c, Type__c FROM Group_Appointment__C WHERE Id = :groupId];
        this.existingAppts = [SELECT Id, Name, Contact__c, Duration__c, Outcome__c, Type__c, Practitioner__c, Start_Date_Time__c, Case__c, Case__r.CaseNumber, Contact__r.Name, Contact__r.Birthdate, Account__r.Name FROM Appointment__c 
                              WHERE Group_Appointment__c = :this.currentGroup.Id AND (Outcome__c = 'Attended on time' OR Outcome__c = 'Arrived late and seen' OR Outcome__c = '')];
        this.numOfAppts = existingAppts.size();
        this.renderSearchTable = false;
        
    }
    
    public List<SelectOption> getAccountPicklist(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        List<Account> accounts = [SELECT Id, Name FROM Account];
        for(Account a : accounts){
            options.add(new SelectOption(a.id, a.name));
        }
        
        return options;
    }
    
    public PageReference attendAll(){
        List<Appointment__c> appts = [SELECT Id, Outcome__c, Name FROM Appointment__c WHERE Group_Appointment__c = :groupId];
        List<Appointment__c> toUpdate = new List<Appointment__c>();
        
        for(Appointment__c a : appts){
            if(a.Outcome__c == null || a.Outcome__c == 'Attended on time'){
            	a.outcome__c = 'Attended on time';
                toUpdate.add(a);
            }else{
                ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Appointment ' + a.Name + ' could not be marked as attended'));
            }
            
        }
        try{
          	update toUpdate;  
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return null;
        
    }
    
    public PageReference caseFromSearch(){
        if(nameSearchText == null || nameSearchText == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No client name entered!'));
        }else if(nameSearchText.length() < 3){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must enter at least 2 characters into the search box!'));
        }else{
            searchCases();
        }
        return null;
    }
    
    public void searchCases(){
        List<Case> cases = new List<case>();
        string queryText = '%' + nameSearchText + '%';
        system.debug(AccountId);
        Set<Id> caseIds = new Set<Id>();
            for(Appointment__c appt : existingAppts){
                caseIDs.add(appt.Case__c);
            }
        if(this.AccountId == null){
            
            cases = [SELECT ID, CaseNumber, Contact.Name, Contact.Birthdate, Owner.Name, Account.Name FROM Case WHERE 
                     Contact.Name LIKE :queryText AND isClosed = false AND Id NOT IN :caseIds LIMIT 20];
        }else{
            
            cases = [SELECT ID, CaseNumber, Contact.Name, Contact.Birthdate, Owner.Name, Account.Name FROM Case WHERE 
                     Contact.Name LIKE :queryText AND AccountId = :AccountID AND isClosed = false AND ID NOT IN :caseIds LIMIT 20];
        }
        this.toSelect = cases;
		this.renderSearchTable = true;        
    }
    
    public PageReference createAppt(){
        Id CaseId = apexpages.currentPage().getParameters().get('addUserTableCU');
        
        Case c = [SELECT ID, ContactId, Contact.Name FROM Case WHERE Id = :CaseID];
        Appointment__c appt = new Appointment__c(Case__c = c.Id, Venue__c = currentGroup.Venue__c, Practitioner__c = currentGroup.Practitioner__c, Type__c = currentGroup.Type__c, Start_date_Time__c = currentGroup.Start_Date_Time__c, Duration__c = currentGroup.Duration__c, Group_Appointment__c = currentGroup.Id, RecordTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Group Appointment').getRecordTypeId());
        try{
            insert(appt);
            system.debug(appt.Name);
            existingAppts.add(appt);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, c.Contact.Name + ' has been successfully added to the group'));
        }catch(Exception ex){
            system.debug('this route');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
      	return null;
        
    }
    
}