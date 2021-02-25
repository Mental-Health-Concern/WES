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
trigger RHX_Questionnaire on Questionnaire__c(after delete, after insert, after undelete, after update, before delete ){
	User runningUser = [SELECT Id, skip_triggers__c, Profile.Name
	                   from user
	                   where id = :userinfo.getUserId()][0];
	if (runningUser.skip_triggers__c != true){
		Type rollClass = System.Type.forName('rh2', 'ParentUtil');
		if (rollClass != null){
			rh2.ParentUtil pu = (rh2.ParentUtil)rollClass.newInstance();
			if (trigger.isAfter){
				pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Questionnaire__c'}, null);
			}
		}
	}
}