/**
 * @File Name          : AppointmentTrigger.trigger
 * @Description        :
 * @Author             : Brodie Lawton
 * @Group              :
 * @Last Modified By   : Brodie Lawton
 * @Last Modified On   : 07-15-2020
 * @Modification Log   :
 * Ver       Date            Author                  Modification
 * 1.0    3/8/2020   Brodie Lawton     Initial Version
 **/
trigger AppointmentTrigger on Appointment__c(before insert, after insert, before update, after update ){
	User runningUser = [SELECT Id, skip_triggers__c, Profile.Name
	                   from user
	                   where id = :userinfo.getUserId()][0];
	if (runningUser.skip_triggers__c != true){
		if (trigger.isBefore){
			AppointmentHelperClass.addAppointmentNumber(trigger.new);
			if (trigger.isInsert){
				AppointmentHelperClass.addAccountAndContact(Trigger.New);
				AppointmentHelperClass.createAppointmentNotes(Trigger.New);
			}
			if (!trigger.isDelete){
				AppointmentHelperClass.checkDateOverlap(Trigger.New);
				AppointmentHelperClass.checkDateOverlapClient(Trigger.New);
				AppointmentHelperClass.updateGroupApptWithDetails(trigger.new);
				AppointmentHelperClass.updateApptWithCharge(trigger.new);
				AppointmentHelperClass.checkAuthorisation(trigger.new);
			}

			if (trigger.isInsert){


			}


		}

		if (trigger.isAfter){
			if (!trigger.isDelete){
				if (trigger.isInsert){
					AppointmentHelperClass.createEvent(Trigger.New);
				}
				if (trigger.isUpdate){

					AppointmentHelperClass.updateEvent(Trigger.New);
					AppointmentHelperClass.deleteAppointmentOnCancel(Trigger.Old);


				}
			}

		}
	}
}