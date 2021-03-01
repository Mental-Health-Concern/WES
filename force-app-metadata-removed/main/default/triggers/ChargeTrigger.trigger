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
trigger ChargeTrigger on Charge__c(before insert, before update ){
	User runningUser = [SELECT Id, skip_triggers__c, Profile.Name
	                   from user
	                   where id = :userinfo.getUserId()][0];
	if (runningUser.skip_triggers__c != true){
		if (trigger.isbefore && trigger.isInsert){
			integer counter = 0;
			for (Charge__c c : trigger.new){
				if (ChargeClass.checkExistingCharges(c, trigger.isInsert) == true){
					trigger.new[counter].addError('An active charge record already exists for this account!');
				}
			}

		}
	}
}