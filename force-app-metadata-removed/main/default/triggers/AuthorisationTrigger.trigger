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
trigger AuthorisationTrigger on Authorisation__c(before insert, after insert, before update, after update ){
	User runningUser = [SELECT Id, skip_triggers__c, Profile.Name
	                   from user
	                   where id = :userinfo.getUserId()][0];
	if (runningUser.skip_triggers__c != true){
		if (Trigger.isBefore){
			if (!trigger.isDelete){
				AuthorisationClass.addErrors(trigger.new);
			}
		}
	}
}