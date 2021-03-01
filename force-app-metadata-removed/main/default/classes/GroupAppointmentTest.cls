@isTest
public class GroupAppointmentTest {
    
    @isTest public static void overlapTest(){
        Account acct = new Account(name = 'Insight Healthcare', WAW_Collect_Employee_Information__c = null, Industry = 'Other', Phone = '011183839445', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insight Service').getRecordTypeId());
        insert acct;
        Venue__c v = new Venue__c(name = 'test', Account__c = acct.Id);
        insert v;
        Group_Appointment__c ga = new Group_Appointment__c (Practitioner__c = UserInfo.getUserId(), Type__c = 'Step 3 Counselling Couples Therapy F2F', Start_Date_Time__c = DateTime.now(), Duration__c = '20', Venue__c = v.id, Max_Number_Of_Attendees__c = 5);
        insert ga;
        Group_Appointment__c ga2 = new Group_Appointment__c (Practitioner__c = UserInfo.getUserId(), Type__c = 'Step 3 Counselling Couples Therapy F2F', Start_Date_Time__c = DateTime.now(), Duration__c = '20', Venue__c = v.id, Max_Number_Of_Attendees__c = 5);
        try{
            insert ga2;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('This appointment overlaps with another active appointment in the practitioners calendar, please check and try again.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
}