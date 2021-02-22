/**
 * @File Name          : QuestionnaireTrigger.trigger
 * @Description        :
 * @Author             : Brodie Lawton
 * @Group              :
 * @Last Modified By   : Brodie Lawton
 * @Last Modified On   : 07-15-2020
 * @Modification Log   :
 * Ver       Date            Author                  Modification
 * 1.0    4/26/2020   Brodie Lawton     Initial Version
 **/
trigger QuestionnaireTrigger on Questionnaire__c(before insert, after insert, before update, after update, before delete, after delete ){
	User runningUser = [SELECT Id, skip_triggers__c, Profile.Name
	                   from user
	                   where id = :userinfo.getUserId()][0];
	if (runningUser.skip_triggers__c != true && !trigger.isDelete){
		if(trigger.isBefore){
			if(trigger.isInsert){
				QuestionnaireClass.addCaseAndAccount(trigger.new);
			}
			else{
				QuestionnaireClass.addCaseAndAccount(trigger.oldMap, trigger.new);
			}
		}
		if (trigger.isAfter){
			update QuestionnaireClass.rollupScores(trigger.new); //updates case with rolled up scores
		}
	}
}