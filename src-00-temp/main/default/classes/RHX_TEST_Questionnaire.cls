@isTest(SeeAllData=true)
public class RHX_TEST_Questionnaire {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Questionnaire__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Questionnaire__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}