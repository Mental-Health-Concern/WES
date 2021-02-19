/**
* @File Name          : AppointmentHelperClass.cls
* @Description        : The class used to power database operations behind the Appointment__c and Group_Appointment__c objects.
* @Author             : Brodie Lawton
* @Group              : 
* @Last Modified By   : Brodie Lawton
* @Last Modified On   : 07-16-2020
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    3/7/2020   	  Ashley Walker     	Initial Version
* 2.0	  19/04/2020	  Brodie Lawton	        Fixed bugs, added charge details, added some reporting field calculations
* 2.1    06/07/2020       Brodie Lawton			No changes made. Added comment block to each class
**/

public class AppointmentHelperClass {
    
    // Name: compareQsAddErrors
    // Description: Helper method for checkDateOverlap. Compares appointment dates (practitioner), and adds errors to appointments which overlap.
    // Written by: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    private static void compareQsAddErrors(SObject currentAppt, String outcome, DateTime newStartDateTime, DateTime oldStartDateTime, DateTime newEndDateTime, DateTime oldEndDateTime) {
        if(outcome == 'Attended on time' || outcome == 'Arrived late and seen' || outcome == '' || outcome == null){
            if((oldStartDateTime >= newStartDateTime) && (oldStartDateTime < newEndDateTime) || (oldEndDateTime > newStartDateTime) && (oldEndDateTime <= newEndDateTime) || (oldStartDateTime <= newStartDateTime) && (oldEndDateTime >= newEndDateTime)) {
                currentAppt.addError('This appointment overlaps with another active appointment in the practitioners calendar, please check and try again.');
            }
        }
    }
    
    // Name: checkDateOverlap
    // Description: Checks appointment overlaps (practitioner)
    // Written by: Ashley Walker
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void checkDateOverlap(Appointment__c [] appointments) {
        List<DateTime> sortedStartDateList = new List<DateTime>();
        List<DateTime> sortedEndDateList = new List<DateTime>();
        for(Appointment__c appt : appointments) {
            sortedStartDateList.add(appt.Start_Date_Time__c);
            sortedEndDateList.add(appt.End_Date_Time__c);
        }
        sortedStartDateList.sort();
        sortedEndDateList.sort();
        DateTime minDate = sortedStartDateList [0];
        DateTime maxDate = sortedEndDateList [sortedEndDateList.size() -1];
        Set<Id> contactId = new Set<Id>();
        for(Appointment__c app :appointments) {
            contactId.add(app.Practitioner__c); //get list of userId's and store them in a set
        }
        
        List<Appointment__c> existingDatesByPractitioner = [SELECT Id, Name, Start_Date_Time__c, End_Date_Time__c
                                                            FROM Appointment__c WHERE Practitioner__c IN :contactId AND ( (End_Date_Time__c <= :maxDate AND Start_Date_Time__c <= :minDate) OR (Start_Date_Time__c >= :minDate AND Start_Date_Time__c <= :maxDate) OR (Start_Date_Time__c <= :minDate AND End_Date_Time__c >= :maxDate) ) AND (outcome__c = 'Attended on time' OR outcome__c = 'Arrived late and seen' OR outcome__c = '')];
        
        List<Group_Appointment__c> existingGroupsByPractitioner = [SELECT ID, Name, Start_Date_Time__c, End_Date_Time__c
                                                            FROM Group_Appointment__c WHERE Practitioner__c IN :contactId AND ( (End_Date_Time__c <= :maxDate AND Start_Date_Time__c <= :minDate) OR (Start_Date_Time__c >= :minDate AND Start_Date_Time__c <= :maxDate) OR (Start_Date_Time__c <= :minDate AND End_Date_Time__c >= :maxDate) )  AND (outcome__c = 'Went ahead as scheduled' OR outcome__c = 'Arrived late and seen' OR outcome__c = '')];
        
        for(Appointment__c appNew : appointments){
            for(Group_Appointment__c appOld : existingGroupsByPractitioner){
                if(appNew.Start_Date_Time__c > appNew.End_Date_Time__c){
                    appNew.addError('Start date cannot be after End Date ');
                } else if((appNew.Id != appOld.Id) && (appNew.RecordTypeId != Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Group Appointment').getRecordTypeId())) {
                    compareQsAddErrors(appNew, appNew.outcome__c, appNew.Start_Date_Time__c, appOld.Start_Date_Time__c, appNew.End_Date_Time__c, appOld.End_Date_Time__c);
                }
            }
        }
        
        for(Appointment__c appNew : Appointments){
            for(Appointment__c appOld : existingDatesByPractitioner){
                if(appNew.Start_Date_Time__c > appNew.End_Date_Time__c){
                    appNew.addError(' Start Date cannot be after End Date.');
                } else if((appNew.Id != appOld.Id) && (appNew.RecordTypeId != Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Group Appointment').getRecordTypeId())) {
                    compareQsAddErrors(appNew, appNew.outcome__c, appNew.Start_Date_Time__c, appOld.Start_Date_Time__c, appNew.End_Date_Time__c, appOld.End_Date_Time__c);
                }
            }
        }
        
    }
    
    // Name: checkDateOverlapClient
    // Description: Checks appointment overlaps (client)
    // Written by: Ashley Walker
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void checkDateOverlapClient(Appointment__c[] appointments){
        Set<Id> contactId = new Set<Id>();
        Set<ID> apptIds = new Set<Id>();
        for(Appointment__c app : appointments){
            contactId.add(app.contact__c);    //get list of userId's and store them in a set
            apptIds.add(app.Id);
        }
        
        List<Appointment__c> existingDatesByClient = [SELECT Id, Name, Start_Date_Time__c, End_Date_Time__c
                                                      FROM Appointment__c WHERE contact__c = :contactId AND(outcome__c = 'Attended on time' OR outcome__c = 'Arrived late and seen' OR outcome__c = null OR outcome__c = '') AND Id NOT IN :apptIds];
        for(Appointment__c appNew :Appointments) {
            for(Appointment__c appOld :existingDatesByClient) {
                if(appNew.Start_Date_Time__c > appNew.End_Date_Time__c) {
                    appNew.addError('Start Date cannot be after End Date.');
                } else if((appOld.Start_Date_Time__c >= appNew.Start_Date_Time__c) && (appOld.Start_Date_Time__c <= appNew.End_Date_Time__c) || (appOld.End_Date_Time__c >= appNew.Start_Date_Time__c) && (appOld.End_Date_Time__c <= appNew.End_Date_Time__c) || (appOld.Start_Date_Time__c <= appNew.Start_Date_Time__c) && (appOld.End_Date_Time__c >= appNew.End_Date_Time__c)) {
                    appNew.addError('This appointment overlaps with another active appointment booked in for this client, please check and try again.');
                }
            }
        }
    }
    
    // Name: addAppointmentNumber
    // Description: Calculates and populates the values for Appointment_Number__c, Attended_Appointment_Number__c & Appointment_Number_Per_Type__c on the Appointment object. Before trigger updates, so returns void
    // Written by: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void addAppointmentNumber(List<Appointment__c> appts){
        set<id> caseIds = new set<id>();
        for(Appointment__c a : appts){
            caseIds.add(a.Case__c);
        }
        List<Appointment__c> currentAppts = [SELECT ID, Start_Date_Time__c, Case__c, Attended__c, Type__c FROM Appointment__c WHERE Case__c IN :caseIDs];
        for(Appointment__c a : appts){
            Map<DateTime, Appointment__c> sortMap = new Map<DateTime, Appointment__c>();
            sortMap.put(a.Start_Date_Time__c, a);
            for(Appointment__c appt : currentAppts){
                if(appt.Case__c == a.Case__c){
                    sortMap.put(appt.Start_Date_Time__c, appt);
                }
            }
            List<DateTime> orderDates = new List<DateTime>();
            List<Appointment__c> sortedValues = new List<Appointment__c>();
            for(Appointment__c appt : sortMap.values()){
                orderDates.add(appt.Start_Date_Time__c);
            }
            orderDates.sort();
            for(DateTime dt : orderDates){
                sortedValues.add(sortMap.get(dt));
            }
            Integer counter = 1; // Appointment_Number__c counter
            Integer counter2 = 1; // Attended_Appointment_Number__c counter
            Integer counter3 = 1; // Appointment_Number_Per_Type__c counter
            for(Appointment__c appt : sortedValues){
                if(appt.Id == a.Id){
                    a.Appointment_Number__c = counter;
                    if(a.Attended__c){
                        a.Attended_Appointment_Number__c = counter2;
                        
                    }
                    if(a.Type__c == appt.Type__c){
                        a.Appointment_Number_Per_Type__c = counter3;
                        
                    }
                    
                }
                if(appt.Attended__c){
                    counter2++;
                }
                if(a.Type__c == appt.Type__c){
                    counter3++;
                }
                counter++;
                
                
            }
            
            
            
        }
    }
    
    // Name: createEvent
    // Description: Creates an event for each Appointment__c. Events are created to power the calander.
    // Written by: Ashley Walker
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void createEvent(Appointment__c [] appointments) {
        List<event> eventList = New List<Event>();
        for(Appointment__c app :appointments) {
            if(app.RecordTypeId != Schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Group Appointment').getRecordTypeID()) {
                Event e = new Event();
                e.subject = app.Contact_Name__c + ' – ' + app.Type__c + ' – ' + app.Start_Date_Time__c.format();
                e.WhoId = app.Contact__c;
                e.OwnerId = app.Practitioner__c;
                e.StartDateTime = app.Start_Date_Time__c;
                e.EndDateTime = app.End_Date_Time__c;
                e.WhatId = app.Id;
                e.ReminderDateTime = e.StartDateTime - (5 /1440);
                e.IsReminderSet = true;
                eventlist.add(e);
            }
            
        }
        try{
            insert eventList;
        } catch(Exception ex) {
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
        
    }
    
    // Name: updateEvent
    // Description: Updates events associated with Appointment__c records. Events are created to power the calander.
    // Written by: Ashley Walker
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void updateEvent(Appointment__c [] appointments) {
        //update the associated event when the appointment record is updated.
        List<event> eventsToUpdate = New List<event>();
        List<Event> events = [SELECT Id, WhatId FROM Event WHERE WhatId IN :appointments ORDER BY CreatedDate ASC];
        Map<Id, Event> map1 = new Map<Id, Event>();
        for(Event e :events) {
            map1.put(e.WhatId, e);
        }
        if(map1.size() > 0) {
            for(Appointment__c app :appointments) {
                Event e = new Event(id = map1.get(app.id).Id);
                e.subject = app.Contact_Name__c + ' – ' + app.Type__c + ' – ' + app.Start_Date_Time__c.format();
                e.WhoId = app.Contact__c;
                e.OwnerId = app.Practitioner__c;
                e.StartDateTime = app.Start_Date_Time__c;
                e.EndDateTime = app.End_Date_Time__c;
                e.WhatId = app.Id;
                e.ReminderDateTime = e.StartDateTime - (5 /1440);
                e.IsReminderSet = true;
                eventsToUpdate.add(e);
            }
        }
        
        try{
            update eventsToUpdate;
        } catch(Exception ex) {
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
    }
    
    // Name: deleteEvent
    // Description: Deletes the event after the appt has been deleted.
    // Written by: Ashley Walker
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void deleteEvent(Appointment__c [] appointments) {
        list<Event> events = New List<Event>();
        for (Appointment__c a :appointments) {
            Events.add(new Event(Id = a.Id));
        }
        delete Events;
    }
    
    // Name: checkAuthorisation
    // Description: Checks to ensure that appointments have been authorised by their contract (on Authorisation__c records), 
    // or have sufficient pre authorised sessions left on their Charge__c record
    // Written by: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void checkAuthorisation(List<Appointment__c> appts) {
        // gets set of charge ids and list of types used in this list of appts. Pulls a list of all Case IDs involved in this list of appts
        Set<Id> chargeIds = new Set<Id>();
        List<String> types = new List<String>();
        Set<Id> CaseIds = new Set<Id>();
        for(Appointment__c a : appts) {
            CaseIds.add(a.Case__c);
            chargeIds.add(a.charge__c);
            types.add(a.Type__c);
        }
        //
        
        //Gets full charge records from ID
        List<Charge__c> charges = [SELECT ID, Type__c, Additional_Appointment_Authorisation__c, Number_of_Sessions_Per_Employee__c, Included_in_Capitated_Fee__c  FROM Charge__c WHERE Id IN :chargeIds];
        //
        
        //Puts charges in map for querying later on
        Map<Id, Charge__c> chargeMap = new Map<Id, Charge__c>();
        for(Charge__c c :charges) {
            chargeMap.put(c.Id, c);
        }
        //
        
        
        //Pulls lists of existing appointments and authorisation records related to the cases invloved and types involved
        List<Appointment__c> existingAppts = [SELECT Id, Case__c, Type__c FROM Appointment__c WHERE Case__c IN :CaseIds AND Type__c IN :types AND(Outcome__c = '' OR Outcome__c = 'Attended on time' OR Outcome__c = 'Arrived late and seen' OR Outcome__c = null)];
        List<Authorisation__c> allAuths = [SELECT Id, Case__c, Type__c, Number_Of_Requested_Sessions__c FROM Authorisation__c WHERE Case__c IN :caseIds AND Type__c IN :types AND Status__c = 'Final Approval - Contract'];
        //
        integer numOfExistingAuthorisations = 0; 
        integer numberOfExistingAppts = 0;
        
        for(Appointment__c a : appts) {
            if(a.Charge__c != null && a.Account__r.WAW_Portal_Authorisation__c == true){
                
                
                
                Charge__c charge = chargeMap.get(a.Charge__c); // Gets charge record related to this appt
                
                if(charge.Additional_Appointment_Authorisation__c != 'No') { // makes sure authorisation is required for appt
                    List<Appointment__c> currentAppts = new List<appointment__c>(); // List for storing other already existing appts on current case
                    
                    for(Appointment__c a2 : existingAppts) {
                        if(a2.Case__c == a.Case__c && a2.Type__c == a.Type__c) {
                            currentAppts.add(a2); // Adds existing appointments of same type to appt list
                        }
                    }
                    numberOfExistingAppts = currentAppts.size(); // Sets number of existing appts
                    
                    for(Authorisation__c auth : allAuths) {
                        if(auth.Case__c == a.Case__c && auth.Type__c == a.Type__c) {
                            numOfExistingAuthorisations = numOfExistingAuthorisations + auth.Number_Of_Requested_Sessions__c.intValue(); // adds previously authorised appts
                            
                        }
                    }
                    
                    if(charge.Number_of_Sessions_Per_Employee__c != null && charge.Included_In_Capitated_Fee__c == 'Yes'){
                        numOfExistingAuthorisations = numOfExistingAuthorisations + charge.Number_of_Sessions_Per_Employee__c.intValue(); // adds pre authorised appts
                    }
                    
                    
                    
                    if(numOfExistingAuthorisations - (numberOfExistingAppts + 1) < 0 && charge.Additional_Appointment_Authorisation__c != 'No'){
                        a.addError('This appointment cannot be created as there are no authorised appointment slots left. Navigate to the authorisation page to request more sessions'); //adds error if there is no authorisation
                    }
                    
                }
                
            }
        }
    }
    
    // Name: deleteEvent
    // Description: Deletes the event after the appointment has been cancelled.
    // Written by: Ashley Walker
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void deleteAppointmentOnCancel(Appointment__c [] appointments) {
        if(appointments.size() != 0) {
            List<Event> events = New List<Event>();
            for(appointment__c app :appointments) {
                if(app.outcome__c != 'Attended on time' && app.outcome__c != 'Arrived late and seen' && app.outcome__c != NULL) {
                    try{
                        Event e = [SELECT Id, WhatId FROM Event WHERE WhatId = :appointments];
                        events.add(e);
                    } catch(Exception ex) {
                        system.debug('No events found');
                        system.debug(ex.getMessage());
                    }
                    
                    
                }
            }
            try{
                delete events;
            } catch(Exception ex) {
                system.debug('Excepation occoured: ' + ex.getMessage());
            }
            
        }
        
    }
    
    // Name: createAppointmentNotes
    // Description: Adds a template from the AppointmentTemplates class to the appointment notes section depending on the appointment type
    // Written by: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void createAppointmentNotes(Appointment__c [] appointments) {
        for(Appointment__c app : appointments) {
            if(app.Appointment_Notes__c == null && app.No_Template__c == false){
                
                    
                if(app.Type__c.contains('Face to Face')) {
                    app.Appointment_Notes__c = AppointmentTemplates.f2fTemplate();
                    
                } else if(app.Type__c.contains('Telephone')) {
                    app.Appointment_Notes__c = AppointmentTemplates.telephoneTherapyTemplate();
                    
                }
            }
            
        }
        
    }
    
    // Name: addAccountAndContact
    // Description: Adds the accountId and ContactId to the Appointment record based on its parent case.
    // Written by: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static List<Appointment__c> addAccountAndContact(List<Appointment__c> appts) {
        List<Appointment__c> toReturn = new List<Appointment__c>();
        for(Appointment__c appt :appts) {
            appt.Account__c = appt.AccountID__c;
            appt.Contact__c = appt.ContactID__c;
            toReturn.add(appt);
        }
        return toReturn;
    }
    
    public static List<Appointment__c> updateApptWithCharge(List<Appointment__c> appts) {
        List<Id> AccountIDs = new List<Id>();
        List<String> types = new List<String>();
        for(Appointment__c a :appts) {
            AccountIds.add(a.AccountID__c);
            types.add(a.Type__c);
        }
        
        List<Charge__c> charges = [SELECT ID, Type__c, Account__c, Start_Date__c, End_Date__c from Charge__c WHERE Account__c IN :AccountIds AND Type__c IN :types ORDER BY Start_Date__c ASC];
        
        if(charges.size() == 0) {
            Integer counter = 0;
            for(Appointment__c a :appts) {
                
                appts[counter].addError('No charge record could be found for this appointment. Please contact ' + a.SYS_Account_Owner_Name__c + ' or another senior member of your service for assistance. Do not contact technical support unless this message is appearing in error.');
                counter++;
                
                
            }
            
        }
        
        
        
        Map<String, List<Charge__c>> chargeMap = new Map<String, List<Charge__c>>();
        List<Charge__c> existingCharges = new List<Charge__c>();
        for(Charge__c c :charges) {
            if(chargeMap.size() > 0) {
                existingCharges = chargeMap.get(c.Type__c);
            }
            
            
            existingCharges.add(c);
            
            chargeMap.put(c.Type__c, existingCharges);
            
            
        }
        
        
        List<Appointment__c> toUpdate = new List<Appointment__c>();
        Integer iteration = 0;
        for(Appointment__c a :appts) {
            List<Charge__c> chargesToSearch = chargeMap.get(a.Type__c);
            
            for(Charge__c c :charges) {
                if(c.Account__c == a.AccountID__C) {
                    
                    if((c.Start_Date__c <= a.Start_Date_Time__c.Date()) && ((c.End_Date__c > a.Start_Date_Time__c.Date()))) {
                        if(a.Charge__c != c.Id) {
                            a.Charge__c = c.Id;
                        }
                    } 
                    
                }
                
            }
            if(a.Charge__c == null){
                appts[iteration].addError('No charge record could be found for this appointment. Please contact the Account Owner, ' + a.SYS_Account_Owner_Name__c + ', or another senior member of your service for assistance. Do not contact technical support unless this message is appearing in error.');
            }
            iteration++;
            
        }
        return toUpdate;
        
    }
    
    // Group Appointments
    
    // Name: updateGroupApptWithDetails
    // Description: Adds start date, duration and practitioner to a group attendee (Appointment__c) record. Changes made in before trigger, so returns void
    // Last Editied / Written By: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void updateGroupApptWithDetails(List<Appointment__c> appointments) { 
        Set<Id> apptIds = new Set<ID>();
        for(appointment__c appt :appointments) {
            apptIds.add(appt.Group_Appointment__c);
        }
        if(apptIds.size() > 0) {
            List<Group_Appointment__c> groupAppts = [SELECT ID, Duration__c, Start_Date_Time__c, End_Date_Time__c, Practitioner__c FROM Group_Appointment__c WHERE Id IN :apptIds];
            Map<Id, Group_Appointment__c> groupMap = new Map<Id, Group_Appointment__c>();
            for(Group_Appointment__c gappt :groupAppts) {
                groupMap.put(gappt.Id, gappt);
            }
            if(groupMap.size() > 0) {
                for(appointment__c a :appointments) {
                    if(a.RecordTypeId == schema.SObjectType.Appointment__c.getRecordTypeInfosByName().get('Group Appointment').getRecordTypeID()) {
                        a.Start_Date_Time__c = groupMap.get(a.Group_Appointment__c).Start_Date_Time__c;
                        a.Duration__c = groupMap.get(a.Group_Appointment__c).Duration__c;
                        a.Practitioner__c = groupMap.get(a.Group_Appointment__c).Practitioner__c;
                    }
                }
            } else {
                system.debug('No Group Appointment in the records submitted');
            }
        }
        
        
    }
    
    // Name: checkForOverlapGroups
    // Description: Checks for and raises an error if the practitioner has a conflict at the time of the current appointment
    // Last Editied / Written By: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void checkForOverlapGroups(List<Group_Appointment__c> groups) {
        set<Id> pracIds = new Set<Id>();
        List<DateTime> sortedStartDateList = new List<DateTime>();
        List<DateTime> sortedEndDateList = new List<DateTime>();
        for(Group_Appointment__c appt :groups) {
            sortedStartDateList.add(appt.Start_Date_Time__c);
            sortedEndDateList.add(appt.End_Date_Time__c);
        }
        sortedStartDateList.sort();
        sortedEndDateList.sort();
        DateTime minDate = sortedStartDateList [0];
        DateTime maxDate = sortedEndDateList [sortedEndDateList.size() -1];
        
        for(Group_Appointment__c g :groups) {
            pracIds.add(g.Practitioner__c);
        }
        
        List<Appointment__c> existingDatesByPractitioner = [SELECT Id, Name, Start_Date_Time__c, End_Date_Time__c
                                                            FROM Appointment__c WHERE Practitioner__c IN :pracIds AND RecordType.Name != 'Group Appointment' AND Start_Date_Time__c >= :minDate AND End_Date_Time__c >= :maxDate AND(outcome__c = 'Attended on time' OR outcome__c = 'Arrived late and seen' OR outcome__c = '')];
        
        List<Group_Appointment__c> existingGroupsByPractitioner = [SELECT Id, Name, Start_Date_Time__c, End_Date_Time__c
                                                                   FROM Group_Appointment__c WHERE Practitioner__c IN :pracIds AND Start_Date_Time__c >= :minDate AND End_Date_Time__c >= :maxDate AND(outcome__c = 'Went ahead as scheduled' OR outcome__c = 'Went ahead with late start')];
        
        for (Group_Appointment__c appNew :groups) {
            for(Group_Appointment__c appOld :existingGroupsByPractitioner) {
                if(appNew.Start_Date_Time__c > appNew.End_Date_Time__c) {
                    appNew.addError('Start date cannot be after End Date');
                } else if(appNew.Id != appOld.Id) {
                    compareQsAddErrors(appNew, appNew.outcome__c, appNew.Start_Date_Time__c, appOld.Start_Date_Time__c, appNew.End_Date_Time__c, appOld.End_Date_Time__c);
                }
            }
        }
        
        
        for(Group_Appointment__c appNew :groups) {
            for(Appointment__c appOld :existingDatesByPractitioner) {
                if(appNew.Start_Date_Time__c > appNew.End_Date_Time__c) {
                    appNew.addError('Start Date cannot be after End Date.');
                } else if(appNew.Id != appOld.Id) {
                    compareQsAddErrors(appNew, appNew.outcome__c, appNew.Start_Date_Time__c, appOld.Start_Date_Time__c, appNew.End_Date_Time__c, appOld.End_Date_Time__c);
                }
            }
        }
    }
    
    // Name: createEventFromGroupAppt
    // Description: Creates an event for the current group appointment to power the practitioners calander
    // Last Editied / Written By: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void createEventFromGroupAppt(Group_Appointment__c [] groups) {
        List<event> eventList = New List<Event>();
        for(Group_Appointment__c app :groups) {
            Event e = new Event();
            e.subject = app.Type__c + ' – ' + app.Start_Date_Time__c.format();
            e.OwnerId = app.Practitioner__c;
            e.StartDateTime = app.Start_Date_Time__c;
            e.EndDateTime = app.End_Date_Time__c;
            e.WhatId = app.Id;
            e.ReminderDateTime = e.StartDateTime - (5 /1440);
            e.IsReminderSet = true;
            eventlist.add(e);
            
        }
        try{
            insert eventList;
        } catch(Exception ex) {
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
        
    }
    
    // Name: updateEventFromGroupAppt
    // Description: Updates an existing event when its associated appointment is changed.
    // Last Editied / Written By: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void updateEventFromGroupAppt(List<Group_Appointment__c> groupAppts) {
        //update the associated event when the appointment record is updated.
        List<event> eventsToUpdate = New List<event>();
        List<Event> events = [SELECT Id, WhatId FROM Event WHERE WhatId IN :groupAppts ORDER BY CreatedDate ASC];
        Map<Id, Event> map1 = new Map<Id, Event>();
        for(Event e :events) {
            map1.put(e.WhatId, e);
        }
        if(map1.size() > 0) {
            for(Group_Appointment__c app :groupAppts) {
                Event e = new Event(id = map1.get(app.id).Id);
                e.subject = app.Type__c + ' – ' + app.Start_Date_Time__c.format();
                e.OwnerId = app.Practitioner__c;
                e.StartDateTime = app.Start_Date_Time__c;
                e.EndDateTime = app.End_Date_Time__c;
                e.WhatId = app.Id;
                e.ReminderDateTime = app.Start_Date_Time__c;
                e.IsReminderSet = true;
                eventsToUpdate.add(e);
            }
        }
        
        try{
            update eventsToUpdate;
        } catch(Exception ex) {
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
    }
    
    // Name: deleteGroupAppOnCancel
    // Description: Deletes the associated event when a group appointment is cancelled.
    // Last Editied / Written By: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void deleteGroupAppOnCancel(Group_Appointment__c [] appointments) {
        if(appointments.size() > 0) {
            List<Event> events = New List<Event>();
            List<Group_Appointment__c> gAppts = new List<Group_Appointment__c>();
            for(Group_Appointment__c app :appointments) {
                if(app.outcome__c != 'Went ahead as scheduled' && app.outcome__c != 'Went ahead with late start' && app.outcome__c != NULL) {
                    gAppts.add(app);
                }
            }
            if(gAppts.size() > 0) {
                events = [SELECT Id From Event WHERE WhatID IN :gAppts];
            }
            try{
                if(events.size() > 0) {
                    delete events;
                }
                
            } catch(Exception ex) {
                system.debug('Exception occoured: ' + ex.getMessage());
            }
            
        }
        
    }
    
    // Name: checkChildAppointmentsOutcome
    // Description: Ensures that all child Appointment__c records have been given an outcome before the parent group appointment is given an outcome.
    // Last Editied / Written By: Brodie Lawton
    // Last Checked / Updated: 06/07/2020
    // Test Classes: Pending
    public static void checkChildAppointmentsOutcome(List<Group_Appointment__c> groups) {
        Set<Id> groupIds = new Set<Id>();
        for(Group_Appointment__c gr :groups) {
            groupIds.add(gr.Id);
        }
        List<Appointment__c> appts = [SELECT ID, Name, Group_Appointment__c FROM Appointment__c WHERE Group_Appointment__c IN :groupIds AND outcome__c = null];
        Map<Id, Appointment__c> apptMap = new Map<Id, Appointment__c>();
        Set<Id> returnedIds = new Set<Id>();
        for(Appointment__c appt :appts) {
            returnedIds.add(appt.Group_Appointment__c);
            apptMap.put(appt.Group_Appointment__c, appt);
        }
        for(Group_Appointment__c ga :groups) {
            if(ga.outcome__c == 'Went ahead as scheduled' || ga.outcome__c == 'Went ahead with late start') {
                if(returnedIds.contains(ga.Id)) {
                    ga.adderror('Appointment: ' + apptMap.get(ga.Id).Name + ' does not have an outcome!');
                }
            }
            
        }
        
    }
    
    
}