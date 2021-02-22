/**
 * @description       : 
 * @author            : Brodie Lawton
 * @group             : 
 * @last modified on  : 07-15-2020
 * @last modified by  : Brodie Lawton
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   07-15-2020   Brodie Lawton   Initial Version
**/
trigger GroupAppointmentTrigger on Group_Appointment__c(before insert, after insert, before update, after update ){
	User runningUser = [SELECT Id, skip_triggers__c, Profile.Name
	                   from user
	                   where id = :userinfo.getUserId()][0];
	if (runningUser.skip_triggers__c != true){
		if (trigger.isBefore){
			if (trigger.isUpdate){
				AppointmentHelperClass.checkChildAppointmentsOutcome(trigger.new);
			}

			if (!trigger.isDelete){
				AppointmentHelperClass.checkForOverlapGroups(trigger.new);
			}

		}
		if (trigger.isAfter){
			if (!trigger.isDelete){
				AppointmentHelperClass.deleteGroupAppOnCancel(trigger.new);
				if (trigger.isUpdate){
					AppointmentHelperClass.updateEventFromGroupAppt(trigger.new);

				}
				if (trigger.isInsert){
					AppointmentHelperClass.createEventFromGroupAppt(trigger.new);
				}
			}
		}
	}
}