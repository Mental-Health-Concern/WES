/**
 * @description       : 
 * @author            : Brodie Lawton
 * @group             : 
 * @last modified on  : 07-14-2020
 * @last modified by  : Brodie Lawton
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   07-14-2020   Brodie Lawton   Initial Version
**/
@isTest
public class AuthorisationTest {
    private static Case getTestData(String questRecordType){
        
        Account a = new Account(Name = 'Test Class', industry = 'Healthcare', WAW_Contract_Start_Date__c = Date.newInstance(2020, 03, 03),
            WAW_Contracted_Role_of_Call_Taker__c = 'Telephone Advisor', WAW_Capitated_Service_Levels__c = 'Helpline Plus', WAW_Contract_End_Date__c = Date.newInstance(2021, 03, 03),
            WAW_Contract_Type__c = 'Capitated', WAW_Employees__c = 'Yes', WAW_Immediate_Family__c = 'No', NumberOfEmployees = 200, WAW_Agreed_Maximum_Annual_Uptake__c = 20,
            WAW_Telephone_Counselling__c = 'Yes', WAW_Billing_Type__c = 'Periodic', WAW_Billing_Frequency__c = 'Monthly', WAW_Reporting_Frequency__c = 'Monthly',
            WAW_Helpline_Number__c = '01758447855', WAW_Collect_Employee_Information__c = '');
        insert a;
        Contact approverC = new contact(FirstName = 'Test', LastName = 'Approver', Title = 'Test Approver', Email = 'test@concerngroup.org', AccountId = a.Id, RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contract Contact').getRecordTypeId());
        insert approverC;
        a.WAW_Authorisation_Contact__c = approverc.Id;
        update a;
        Profile p = [SELECT Id FROM Profile WHERE Name='WaW Customer Community Plus User'];
        User contractUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, ContactId = approverc.id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert contractUser;
        Charge_Year__c cp = new Charge_Year__c(Account__c = a.Id, Yearly_Fee__c = 200000, Start_Date__c = Date.newInstance(2020, 03, 03), End_Date__c = Date.newInstance(2021, 03, 03));
        insert cp;
        Charge__c charge = new Charge__c(Account__c = a.Id, Charge_Year__c = cp.Id, Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 0, Additional_Session_Fee__c = 0, Type__c = 'Helpline Call', Included_in_Capitated_Fee__c = 'Yes',
            Start_Date__c = Date.newInstance(2020, 03, 03), End_Date__c = Date.newInstance(2021, 03, 03));
        Charge__c charge2 = new Charge__c(Account__c = a.Id, Charge_Year__c = cp.Id, Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 0, Additional_Session_Fee__c = 0, Type__c = 'Step 3 Counselling Telephone', Included_in_Capitated_Fee__c = 'Yes',
            Start_Date__c = Date.newInstance(2020, 03, 03), End_Date__c = Date.newInstance(2021, 03, 03));
        insert charge;
        insert charge2;
        CCG__c ccg = new CCG__c (name = 'NHS TEST CCG', CCG_Code__c = '22C', Address_Line_1__c = 'CCG Headquaters', Postcode__c = 'TE55 7TT');
        insert ccg;
        Surgery__c s = new Surgery__c (CCG__c = ccg.Id, NHS_Practice_Code__c = 'Test 01');
        insert s;
        Contact contact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WAW Client').getRecordTypeId(),AccountId = a.Id, FirstName = 'Test', LastName = 'Class', MobilePhone = '07977531595', Emergency_Info_Declined__c = true, MailingStreet = 'Hill House', MailingCity = 'Test', MailingPostalCode = 'TD4 FFS', Surgery__c = s.Id);
        insert contact;
        Case case1 = new case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('WAW Case').getRecordTypeId(), ContactId = contact.Id, AccountId = a.Id, Status = 'New', type = 'Helpline Call', Referral_Date__c = Date.newinstance(2020, 03, 03), Initial_Presenting_Problem__c = 'Addictions - Alcohol', Description = 'Test',
            WAW_Displaying_Risk_on_First_Contact__c = 'No');
        insert case1;
        Test.setCreatedDate(case1.Id, DateTime.NewInstance(2020, 03, 04, 00, 00, 00));
        Appointment__c appt = new Appointment__c(RecordTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Assessment').getRecordTypeId(), Case__c = case1.Id, Practitioner__c = UserInfo.getUserId(), Type__c = 'Helpline Call', Outcome__c = 'Attended on time', Start_Date_Time__c = DateTime.newInstance(2020, 05, 05, 12, 00, 00), Duration__c = '5', Assessment_Recomendation__c = 'No Further Treatment Recommended', WAW_Focus_for_Treatment__c = 'test', WAW_Assessment_Risk__c = 'test', WAW_Specific_Client_Information_Needs__c = 'test', WAW_Any_Other_Relevant_Information__c = 'test');
        insert appt;
        Questionnaire__c quest1 = new Questionnaire__c(RecordTypeID = Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get(questRecordType).getRecordTypeId(), Appointment__c = appt.Id,  CX_I_have_felt_I_have_someone__c = 'Not at all', CX_I_have_felt_able_to_cope_when__c = 'Not at all', CX_I_have_felt_despairing_or_hopeless__c = 'Not at all', CX_I_have_felt_panic_or_terror__c = 'Not at all', CX_I_have_felt_tense_anxious__c = 'Not at all', CX_I_have_felt_unhappy__c = 'Not at all', CX_I_have_had_difficulty_getting_to__c = 'Not at all', CX_I_have_made_plans_to_end_my_life__c = 'Not at all', CX_Talking_to_people_has_felt_too_c__c = 'Not at all', CX_Unwanted_images_or_memories_have_bee__c = 'Not at all', GAD7_Becoming_easily_annoyed__c = '1', GAD7_Being_so_restless_that_it_is_hard__c = '1', GAD7_Feeling_afraid_as_if_something__c = '1', GAD7_Feeling_nervous_anxious_or_on_edge__c = '1', GAD7_Not_being_able_to_stop_or_control__c = '1', GAD7_Trouble_relaxing__c = '1', GAD7_Worrying_too_much_about_different__c = '2', PHQ9_Feeling_bad_about_yourself__c = '1', PHQ9_Feeling_down_depressed_or_hopeless__c = '1', PHQ9_Feeling_tired_or_having_little__c = '1', PHQ9_Little_Interest_or_pleasure_in__c = '1', PHQ9_Moving_or_speaking_so_slowly_that__c = '1', PHQ9_Poor_appetite_or_overeating__c = '1', PHQ9_Thoughts_that_you_would_be_better__c = '1', PHQ9_Trouble_concentrating_on_things__c = '1', PHQ9_Trouble_falling_or_staying_asleep__c = '2');
        insert quest1;
        Appointment__c appt2 = new Appointment__c(RecordTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Assessment').getRecordTypeId(), Case__c = case1.Id, Practitioner__c = UserInfo.getUserId(), Type__c = 'Helpline Call', Outcome__c = 'Attended on time', Start_Date_Time__c = DateTime.newInstance(2020, 05, 06, 12, 00, 00), Duration__c = '5', Assessment_Recomendation__c = 'No Further Treatment Recommended');
        insert appt2;
        Questionnaire__c quest2 = new Questionnaire__c(RecordTypeID = Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get(questRecordType).getRecordTypeId(), Appointment__c = appt2.Id,  CX_I_have_felt_I_have_someone__c = 'Not at all', CX_I_have_felt_able_to_cope_when__c = 'Not at all', CX_I_have_felt_despairing_or_hopeless__c = 'Not at all', CX_I_have_felt_panic_or_terror__c = 'Not at all', CX_I_have_felt_tense_anxious__c = 'Not at all', CX_I_have_felt_unhappy__c = 'Not at all', CX_I_have_had_difficulty_getting_to__c = 'Not at all', CX_I_have_made_plans_to_end_my_life__c = 'Not at all', CX_Talking_to_people_has_felt_too_c__c = 'Not at all', CX_Unwanted_images_or_memories_have_bee__c = 'Only occasionally', GAD7_Becoming_easily_annoyed__c = '1', GAD7_Being_so_restless_that_it_is_hard__c = '1', GAD7_Feeling_afraid_as_if_something__c = '1', GAD7_Feeling_nervous_anxious_or_on_edge__c = '1', GAD7_Not_being_able_to_stop_or_control__c = '1', GAD7_Trouble_relaxing__c = '1', GAD7_Worrying_too_much_about_different__c = '1', PHQ9_Feeling_bad_about_yourself__c = '1', PHQ9_Feeling_down_depressed_or_hopeless__c = '1', PHQ9_Feeling_tired_or_having_little__c = '1', PHQ9_Little_Interest_or_pleasure_in__c = '1', PHQ9_Moving_or_speaking_so_slowly_that__c = '1', PHQ9_Poor_appetite_or_overeating__c = '1', PHQ9_Thoughts_that_you_would_be_better__c = '1', PHQ9_Trouble_concentrating_on_things__c = '1', PHQ9_Trouble_falling_or_staying_asleep__c = '1');
        insert quest2;
        return case1;
    }
	private static Case getTestDataNoQuests(){
        Account a = new Account(Name = 'Test Class', industry = 'Healthcare', WAW_Contract_Start_Date__c = Date.newInstance(2020, 03, 03),
            WAW_Contracted_Role_of_Call_Taker__c = 'Telephone Advisor', WAW_Capitated_Service_Levels__c = 'Helpline Plus', WAW_Contract_End_Date__c = Date.newInstance(2021, 03, 03),
            WAW_Contract_Type__c = 'Capitated', WAW_Employees__c = 'Yes', WAW_Immediate_Family__c = 'No', NumberOfEmployees = 200, WAW_Agreed_Maximum_Annual_Uptake__c = 20,
            WAW_Telephone_Counselling__c = 'Yes', WAW_Billing_Type__c = 'Periodic', WAW_Billing_Frequency__c = 'Monthly', WAW_Reporting_Frequency__c = 'Monthly',
            WAW_Helpline_Number__c = '01758447855', WAW_Collect_Employee_Information__c = '');
        insert a;
        Charge_Year__c cp = new Charge_Year__c(Account__c = a.Id, Yearly_Fee__c = 200000, Start_Date__c = Date.newInstance(2020, 03, 03), End_Date__c = Date.newInstance(2021, 03, 03));
        insert cp;
        Charge__c charge = new Charge__c(Account__c = a.Id, Charge_Year__c = cp.Id, Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 0, Additional_Session_Fee__c = 0, Type__c = 'Helpline Call', Included_in_Capitated_Fee__c = 'Yes',
            Start_Date__c = Date.newInstance(2020, 03, 03), End_Date__c = Date.newInstance(2021, 03, 03));
        Charge__c charge2 = new Charge__c(Account__c = a.Id, Charge_Year__c = cp.Id, Additional_Appointment_Authorisation__c = 'No', Fee_For_Service_Cost__c = 0, Additional_Session_Fee__c = 0, Type__c = 'Step 3 Counselling Face to Face', Included_in_Capitated_Fee__c = 'No',
            Start_Date__c = Date.newInstance(2020, 03, 03), End_Date__c = Date.newInstance(2021, 03, 03));
        insert charge;
        insert charge2;
        CCG__c ccg = new CCG__c (name = 'NHS TEST CCG', CCG_Code__c = '22C', Address_Line_1__c = 'CCG Headquaters', Postcode__c = 'TE55 7TT');
        insert ccg;
        Surgery__c s = new Surgery__c (CCG__c = ccg.Id, NHS_Practice_Code__c = 'Test 01');
        insert s;
        Contact contact = new Contact(RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WAW Client').getRecordTypeId(),AccountId = a.Id, FirstName = 'Test', LastName = 'Class', MobilePhone = '07977531595', Emergency_Info_Declined__c = true, MailingStreet = 'Hill House', MailingCity = 'Test', MailingPostalCode = 'TD4 FFS', Surgery__c = s.Id);
        insert contact;
        Case case1 = new case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('WAW Case').getRecordTypeId(), ContactId = contact.Id, AccountId = a.Id, Status = 'New', type = 'Helpline Call', Referral_Date__c = Date.newinstance(2020, 03, 03), Initial_Presenting_Problem__c = 'Addictions - Alcohol', Description = 'Test',
            WAW_Displaying_Risk_on_First_Contact__c = 'No');
        insert case1;
        Test.setCreatedDate(case1.Id, DateTime.NewInstance(2020, 03, 04, 00, 00, 00));
        Appointment__c appt = new Appointment__c(RecordTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Assessment').getRecordTypeId(), Case__c = case1.Id, Practitioner__c = UserInfo.getUserId(), Type__c = 'Helpline Call', Outcome__c = 'Attended on time', Start_Date_Time__c = DateTime.newInstance(2020, 05, 05, 12, 00, 00), Duration__c = '5', Assessment_Recomendation__c = 'No Further Treatment Recommended');
        insert appt;
        return case1;
    }    
    
    @isTest public static void doubleAuthCheck(){
        Case c = getTestData('CORE10');
        Account acct = [SELECT Id, WAW_Authorisation_Contact__c, OwnerId FROM Account LIMIT 1];
        Authorisation__c auth1 = new Authorisation__c(Type__c = 'Step 3 Counselling Face to Face', Case__c = c.Id, Supporting_Comments__c = 'test', Date_Time_Opened__c = DateTime.now(), Number_of_requested_sessions__c = 6, Status__c = 'Submitted', Authorisation_Contact__c = acct.WAW_Authorisation_Contact__c, Contract_Manager__c = acct.OwnerId);
        insert auth1;
        Authorisation__c auth2 = new Authorisation__c(Type__c = 'Step 3 Counselling Face to Face', Case__c = c.Id, Supporting_Comments__c = 'test', Date_Time_Opened__c = DateTime.now(), Number_of_requested_sessions__c = 6, Status__c = 'Submitted', Authorisation_Contact__c = acct.WAW_Authorisation_Contact__c, Contract_Manager__c = acct.OwnerId);
        try{
            insert auth2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('There is already an open approval request against this case!') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
}