@isTest 
public class TestDataFactory{
    
    public static integer getRandom(){
        return Math.round((Math.random() * (9000) + 1000));
        
    }    
    
    public static List<Account> createAccounts(integer numAcc, Boolean doInsert) {
        List<Account> accts = new List<Account>();
        for (Integer i = 0; i < numAcc; i++ ){
            //add accounts
            accts.add(new Account(name = 'Test Account ' + Math.round((Math.random() * (9000) + 1000)),
                                  Industry = 'None',
                                  WAW_Immediate_Family__c = 'Yes',
                                  WAW_Collect_Employee_Information__c = 'No', 
                                  WAW_Contract_Start_Date__c = system.today().addYears(-2)));
            
        }
        if(doInsert){
            
            
            insert accts;
            
            
            
        }
        return accts;
    }
    
    public static void insertChargeInfo(Id accountId, Date startDate, Date endDate){
        Charge_Year__c cy = new Charge_Year__c (Account__c = accountId, Yearly_Fee__c = 0, Start_Date__c = startDate, End_Date__c = endDate);
        insert cy;
        Charge__c c1 = new charge__c(Account__c = accountId, Charge_Year__c = cy.Id, Type__c = 'Helpline Call', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = startDate, End_Date__c = endDate, Included_in_Capitated_Fee__c = 'Yes');
        insert c1;
        Charge__c c2 = new charge__c(Account__c = accountId, Charge_Year__c = cy.Id, Type__c = 'Step 2 GSH (Book) Email', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = startDate, End_Date__c = endDate, Included_in_Capitated_Fee__c = 'Yes');
        insert c2;
        Charge__c c3 = new charge__c(Account__c = accountId, Charge_Year__c = cy.Id, Type__c = 'Step 2 GSH (Book) Telephone', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = startDate, End_Date__c = endDate, Included_in_Capitated_Fee__c = 'Yes');
        insert c3;
        system.debug('CHARGES CREATED TEST CLASS LINE 40');
    }
    
    public static List<CCG__c> CreateCCG(Integer numCCG, Boolean doInsert) {
        List<CCG__c> CCGs = new List <CCG__c>();
        //List<Account> accts = createAccounts(1, false);
        //List<Contact> cons = createContact(1, false);
        for(integer i = 0; i < numCCG; i++) {
            CCGs.add(new CCG__c(Name = 'Test CCG ' + i,
                                CCG_Code__c = string.valueOf(getRandom()),
                                Postcode__c = 'NE12 4QQ'));
        }
        if (doInsert){
            insert CCGs;
        }
        return CCGs;
    }
    
    public static List<User> createPractitioner(Integer numUser, Boolean doInsert){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<User> users= new List<User>();
        
        users.add(new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com' + Math.round((Math.random() * (9000) + 1000))));
        insert users;
        
        return users;
    }
    
    public static List<Surgery__c> createSurgery(Integer numSurgeries , Boolean doInsert){
        List<Surgery__c> surgeries = new List<Surgery__c>();  
        List<CCG__c> CCGs = createCCG(1, false);
        for (integer i; i < numSurgeries; i++){
            surgeries.add(new Surgery__c(Name = 'test surgery ' + i,
                                         CCG__c = CCGs[i].Id));
        }
        if(doInsert){
            insert surgeries;
        }
        return surgeries;
    } 
    
    public static List<Contact> createContact(integer numContact, Boolean doInsert) {
        List <Contact> cons = new List <Contact>();
        List<Surgery__c> surgeries = createSurgery(1, false);
        List <Account> accts = createAccounts(1, false);
        for (Integer i = 0; i < numContact; i++) {
            cons.add(new Contact(FirstName = 'Test', LastName = 'User ' + i, 
                                 accountid = accts[i].Id, 
                                 surgery__c = surgeries[i].Id
                                ));
        }
        if(doInsert){
            insert cons;
        }
        return cons;
    }
    
    public static List<Case> createCase(Integer numCases, Boolean doInsert) {
        List<Case> Cases = new List <Case>();
        List<Account> accts = createAccounts(1, false);
        List<Contact> cons = createContact(1, false);
        for(integer i = 0; i < numCases; i++) {
            Cases.add(new Case(ContactId = cons[i].Id,
                               AccountId = accts[i].Id,
                               Status = 'New',
                               Type = 'Waiting',
                               Origin = 'Helpline Call',
                               Priority = 'Medium',
                               Initial_Presenting_Problem__c = 'ADHD'
                              ));
        }
        if (doInsert){
            insert Cases;
        }
        return Cases;
    }    
    
    public static List<Appointment__c> createAppointment(integer numAppointments, Boolean doInsert, DateTime appStartDate, String appDuration) {
        
        List<Appointment__c> appointments = new List<Appointment__c>();
        List<Account> accts = createAccounts(1, true);
        List<Contact> cons = createContact(1, true);
        List<Case> cse = createCase(1, true);
        List<User> u = createPractitioner(1, true);
        
        Id RecordTypeIdAppointment = Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Assessment').getRecordTypeId(); 
        for(integer i; i < numAppointments; i++) {
            
            appointments.add(new Appointment__c(RecordTypeId = RecordTypeIdAppointment,
                                                Start_Date_Time__c = appStartDate,
                                                Duration__c = appDuration,
                                                
                                                Account__c = accts[i].Id,
                                                Contact__c = cons[i].Id,
                                                Case__c = cse[i].Id,
                                                Practitioner__c = u[i].Id,
                                                Type__c = 'Helpline Call'
                                               ));
        }
        Set<Id> accountIds = new Set<Id>();
        
        for(Appointment__c a : appointments){
            accountIds.add(a.Account__c);
            
        }
        for(Id accountId : accountIds){
            system.debug('CHARGE TEST CALLED');
            insertChargeInfo(accountId, Date.NewInstance(appStartDate.year(), appStartDate.month(), appStartDate.day()), Date.newInstance(appStartDate.year()+1, appStartDate.month(), appStartDate.Day()));
        }
        if(doInsert) {
            insert appointments;
        }
        return appointments;
    }
    
    
    
    
    
    
    public static List<Appointment__c> createAllAppointmentData(datetime appStartDate, String appDuration){
        
        Account a = new Account(name = 'Test Account ' + Math.round((Math.random() * (9000) + 1000)),                                                                               
                                Industry = 'None',
                                WAW_Immediate_Family__c = 'Yes',
                                WAW_Collect_Employee_Information__c = 'No', 
                                WAW_Contract_Start_Date__c = system.today().addYears(-2));
        insert a;
        
        CCG__c c = new CCG__C(Name = 'Test CCG',
                              CCG_Code__c = string.valueOf(getRandom()),
                              Postcode__c = 'NE12 4QQ');
        insert c;
        
        surgery__c s  = new Surgery__c(Name = 'test surgery',
                                       CCG__c = c.Id,
                                       NHS_Practice_Code__c = string.valueOf(getRandom()));
        
        insert s;
        
        contact con = new contact(FirstName = 'Test',
                                  LastName = 'contact',
                                  AccountId = a.Id,
                                  Surgery__c = s.Id,
                                  Emergency_Info_Declined__c = TRUE);
        
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', 
                          Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8',
                          LastName='Testing',
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US',
                          ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='standarduser@testorg.com' + Math.round((Math.random() * (9000) + 1000)));
        insert u;
        
        case ca = new case(ContactId = con.Id,
                           AccountId = a.Id,
                           Status = 'New',
                           Type = 'Helpline Call',
                           Origin = 'Helpline Call',
                           Priority = 'Medium',
                           Initial_Presenting_Problem__c = 'ADHD');
        
        insert ca;
        
        /*Id RecordTypeIdRisk= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Clinical_Risk').getRecordTypeId();

Risk__c rsk = new Risk__c(Account__c = a.Id,
Case__c = ca.Id,
Contact__c = con.Id,
Risk_Rating_Before_Review__c = 'Red',
Risk_Rating_Agreed__c = 'Red',
recordTypeId = RecordTypeIdRisk,
Date_Raised__c = system.today());
insert rsk;*/
        
        Venue__c v = new Venue__c(Name = 'TestVenue',
                                  Account__c = a.Id);
        
        insert v;
        
        Charge_Year__c cy = new Charge_Year__c (Account__c = a.Id, Yearly_Fee__c = 0, Start_Date__c = appStartDate.date(), End_Date__c = appStartDate.date()+10);
        insert cy;
        Charge__c c1 = new charge__c(Account__c = a.Id, Charge_Year__c = cy.Id, Type__c = 'Helpline Call', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = appStartDate.date(), End_Date__c = appStartDate.date()+10, Included_in_Capitated_Fee__c = 'Yes');
        insert c1;
        Charge__c c2 = new charge__c(Account__c = a.Id, Charge_Year__c = cy.Id, Type__c = 'Step 2 GSH (Book) Email', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = appStartDate.date(), End_Date__c = appStartDate.date()+10, Included_in_Capitated_Fee__c = 'Yes');
        insert c2;
        Charge__c c3 = new charge__c(Account__c = a.Id, Charge_Year__c = cy.Id, Type__c = 'Step 2 GSH (Book) Telephone', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = appStartDate.date(), End_Date__c = appStartDate.date()+10, Included_in_Capitated_Fee__c = 'Yes');
        insert c3;
        
        Id AssessmentRT = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Id F2fRT = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Treatment').getRecordTypeId();
        List<appointment__c> appointments = new List<Appointment__c>();
        appointment__c ap = new appointment__c(Start_Date_Time__c = appStartDate,
                                               Duration__c = appDuration,
                                               Account__c = a.Id,
                                               Contact__c = con.Id,
                                               Case__c = ca.Id,
                                               Practitioner__c = u.Id,
                                               RecordTypeId = AssessmentRT,
                                               Type__c = 'Helpline Call');
        
        
        appointment__c apf2f = new appointment__c(Start_Date_Time__c = appStartDate,
                                                  Duration__c = appDuration,
                                                  Account__c = a.Id,
                                                  Contact__c = con.Id,
                                                  Case__c = ca.Id,
                                                  Practitioner__c = u.Id,
                                                  Venue__c = v.Id,
                                                  RecordTypeId = F2fRT,
                                                  Type__c = 'Step 2 GSH (Book) Email');
        
        appointment__c aptele = new appointment__c(Start_Date_Time__c = appStartDate,
                                                   Duration__c = appDuration,
                                                   Account__c = a.Id,
                                                   Contact__c = con.Id,
                                                   Case__c = ca.Id,
                                                   Practitioner__c = u.Id,
                                                   Venue__c = v.Id,
                                                   RecordTypeId = F2fRT,
                                                   Type__c = 'Step 2 GSH (Book) Telephone');
        appointments.add(ap);
        appointments.add(apf2f);
        appointments.add(aptele);
        
        
        
        insert appointments;
        
        return appointments;
    }         
    
    
    
    public static void createAllAppointmentData(datetime appStartDate, String appDuration, String appType){
        
        Account a = new Account(name = 'Test Account ' + Math.round((Math.random() * (9000) + 1000)),                                                                               
                                Industry = 'None',
                                WAW_Immediate_Family__c = 'Yes',
                                WAW_Collect_Employee_Information__c = 'No', 
                                WAW_Contract_Start_Date__c = system.today().addYears(-2));
        insert a;
		
        Charge_Year__c cy = new Charge_Year__c (Account__c = a.Id, Yearly_Fee__c = 0, Start_Date__c = appStartDate.date(), End_Date__c = appStartDate.date()+10);
        insert cy;
        Charge__c c1 = new charge__c(Account__c = a.Id, Charge_Year__c = cy.Id, Type__c = 'Helpline Call', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = appStartDate.date(), End_Date__c = appStartDate.date()+10, Included_in_Capitated_Fee__c = 'Yes');
        insert c1;
        Charge__c c2 = new charge__c(Account__c = a.Id, Charge_Year__c = cy.Id, Type__c = 'Step 2 GSH (Book) Email', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = appStartDate.date(), End_Date__c = appStartDate.date()+10, Included_in_Capitated_Fee__c = 'Yes');
        insert c2;
        Charge__c c3 = new charge__c(Account__c = a.Id, Charge_Year__c = cy.Id, Type__c = 'Step 2 GSH (Book) Telephone', Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 25, Additional_Session_Fee__c = 25, Start_Date__c = appStartDate.date(), End_Date__c = appStartDate.date()+10, Included_in_Capitated_Fee__c = 'Yes');
        insert c3;

        CCG__c c = new CCG__C(Name = 'Test CCG',
                              CCG_Code__c = string.valueOf(getRandom()),
                              Postcode__c = 'NE12 4QQ');
        insert c;
        
        surgery__c s  = new Surgery__c(Name = 'test surgery',
                                       CCG__c = c.Id,
                                       NHS_Practice_Code__c = '123456'
                                      );
        
        insert s;
        
        contact con = new contact(FirstName = 'Test',
                                  LastName = 'contact', 
                                  accountid = a.Id, 
                                  surgery__c = s.Id,
                                  Emergency_Info_Declined__c = TRUE);
        
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com' + Math.round((Math.random() * (9000) + 1000)));
        insert u;
        
        case ca = new case(ContactId = con.Id,
                           AccountId = a.Id,
                           Status = 'New',
                           Type = 'Waiting',
                           Origin = 'Helpline Call',
                           Priority = 'Medium',
                           Initial_Presenting_Problem__c = 'ADHD'
                          );
        
        insert ca;
        
        appointment__c ap = new appointment__c(Start_Date_Time__c = appStartDate,
                                               Duration__c = appDuration,
                                               Account__c = a.Id,
                                               Contact__c = con.Id,
                                               Case__c = ca.Id,
                                               Practitioner__c = u.Id,
                                               Type__c = apptype);
        insert ap;
        
        /*Id RecordTypeIdRisk= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Clinical_Risk').getRecordTypeId();

Risk__c rsk = new Risk__c(Account__c = a.Id,
Case__c = ca.Id,
Contact__c = con.Id,
Risk_Rating_Before_Review__c = 'Red',
Risk_Rating_Agreed__c = 'Red',
recordTypeId = RecordTypeIdRisk,
Date_Raised__c = system.today());
insert rsk;*/
    }              
}