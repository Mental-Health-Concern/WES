@isTest(SeeAllData=true)
public class RHX_TEST_Appointment {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Appointment__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Appointment__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}