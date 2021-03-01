/**
 * @description       : 
 * @author            : Brodie Lawton
 * @group             : 
 * @last modified on  : 07-13-2020
 * @last modified by  : Brodie Lawton
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   07-13-2020   Brodie Lawton   Initial Version
**/
@isTest
public class CaseTesting {
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
        return case1;
    }
    @isTest public static void testbeforeUpdate1 (){
        getTestDataNoQuests();
        Case c = [SELECT ID, Status FROM Case LIMIT 1];
        c.status = 'Discharged';
        c.Reason = 'Completed Treatment - with clinical intervention';
        Database.SaveResult srList = Database.update(c, false);

        system.assertEquals(srList.isSuccess(), false);
    }
}