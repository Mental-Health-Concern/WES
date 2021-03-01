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
trigger CaseTrigger on Case(before insert, after insert, before update, after update, before delete ){
	User runningUser = [SELECT Id, skip_triggers__c, Profile.Name
	                   from user
	                   where id = :userinfo.getUserId()][0];
	if (runningUser.skip_triggers__c != true){
		CaseClass cClass = new CaseClass();
		if (trigger.isBefore && trigger.isUpdate){
			cClass.beforeUpdate(trigger.new);

		}
	}
}