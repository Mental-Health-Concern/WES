/**
 * @description       : Central class to coordinate calling Rollup Helper package to process the
 *                      rollup reassessments for any object in real time. Class is invoked by creating
 *                      Trigger Action metadata records for relevant contexts on the object (see Account 
 *                      records to illustrate)
 * @author            : Lawrence Newcombe
 * @group             : 
 * @last modified on  : 26-02-2021
 * @last modified by  : Lawrence Newcombe
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   26-02-2021   Lawrence Newcombe   Initial Version
**/


public without sharing class TA_SObjectTriggerRollups implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.AfterUndelete, TriggerAction.BeforeDelete {

    public void afterInsert(List<SObject> newList) {
        processWithNewList(newList);
    }

    public void afterUpdate(List<SObject> newList, List<SObject> oldList) {
        processWithBothLists(newList, oldList);
    }

    public void afterDelete(List<SObject> oldList) {
        processWithOldList(oldList, true);
    }

    public void afterUndelete(List<SObject> newList) {
        processWithNewList(newList);
    }

    public void beforeDelete(List<SObject> oldList) {
        processWithOldList(oldList, false);
    }


    // Get object name in scope and convert lists to maps
    private void processWithNewList(List<SObject> newList) {
        String thisObjectName = newList[0].getSObjectType().getDescribe().getName();
        Map<Id,SObject> newMap = new Map<Id,SObject>(newList);
        performRollups(newMap, null, thisObjectName, true);
    }

    private void processWithOldList(List<SObject> oldList, Boolean isAfter) {
        String thisObjectName = oldList[0].getSObjectType().getDescribe().getName();
        Map<Id,SObject> oldMap = new Map<Id,SObject>(oldList);
        performRollups(null, oldMap, thisObjectName, isAfter);
    }

    private void processWithBothLists(List<SObject> newList, List<SObject> oldList) {
        String thisObjectName = newList[0].getSObjectType().getDescribe().getName();
        Map<Id,SObject> newMap = new Map<Id,SObject>(newList);
        Map<Id,SObject> oldMap = new Map<Id,SObject>(oldList);
        performRollups(newMap, oldMap, thisObjectName, true);
    }


    // Call to performTriggerRollups follows structure of https://www.passagetechnology.com/rollup-helper-admin-guide
    // (Developer Guide in "Enable Real Time Rollups" section)
    private void performRollups(Map<Id,SObject> oldMap, Map<Id,SObject> newMap, String thisObjectName, Boolean isAfter) {
        Type rollClass = System.Type.forName('rh2', 'ParentUtil');
    
        if(rollClass != null) {
            rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();

            if (isAfter) {
                pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{thisObjectName}, null);
            }
        }
    }

}
