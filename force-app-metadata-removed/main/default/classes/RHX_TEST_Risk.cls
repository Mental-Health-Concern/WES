@isTest(SeeAllData=true)
public class RHX_TEST_Risk {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Risk__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Risk__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}