/**
 * @description       : 
 * @author            : Brodie Lawton
 * @group             : 
 * @last modified on  : 07-15-2020
 * @last modified by  : Brodie Lawton
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   07-15-2020   Brodie Lawton     Initial Version
 * 1.1   02-15-2020   Lawrence Newcombe Migrated to trigger actions framework, bulkified to avoid SOQL limits
**/


public without sharing class ChargeActionCheckOverlaps implements TriggerAction.beforeInsert {

    public void beforeInsert(List<Charge__c> newList) {
        checkExistingCharges(newList);
    }

    // Also include before update?


    public void checkExistingCharges(List<Charge__c> newCharges) {

        // Get lists of types and accountIds from new charge list
        List<Id> chargeAccountIds = new List<Id>();
        List<String> chargeTypes = new List<String>();
        for (Charge__c c : newCharges) {
            chargeAccountIds.add(c.Account__c);
            chargeTypes.add(c.Type__c);
        }

        Map<String,List<Charge__c>> existingChargesMap = getMapOfChargesForAccountsAndTypes(chargeAccountIds, chargeTypes);

        // For each charge, get the list matching account and type and add errors if overlaps
        for(Charge__c c : newCharges) {
            String key =  c.Account__c + c.Type__c;
            if(existingChargesMap.containsKey(key)) {
                addErrorIfOverlaps(c, existingChargesMap.get(key));
            }
        }
    }


    // Query for charges and build map of lists with account+type key
    Map<String,List<Charge__c>> getMapOfChargesForAccountsAndTypes(List<Id> chargeAccountIds, List<String> chargeTypes) {

        // Query for existing charges on these accounts
        List<Charge__c> existingCharges = [SELECT Id, Start_Date__c, End_Date__c, Account__c, Type__c
            FROM Charge__c 
            WHERE Type__c IN :chargeTypes AND Account__c IN :chargeAccountIds];

        // Build map with account & type key
        Map<String,List<Charge__c>> existingChargesMap = new Map<String,List<Charge__c>>();
        for(Charge__c c : existingCharges) {
            String key = c.Account__c + c.Type__c;
            List<Charge__c> chargesForTypeAndAccount;

            // If we've already started a list for this combination, get this
            if(existingChargesMap.containsKey(key)) {
                chargesForTypeAndAccount = existingChargesMap.get(key);
            }

            // Otherwise initialise new charges list
            else {
                chargesForTypeAndAccount = new List<Charge__c>();
            }

            // Add this charge to the list (assuming this isn't a modified charge) and put this in the map
            chargesForTypeAndAccount.add(c);
            existingChargesMap.put(key, chargesForTypeAndAccount);
        }

        return existingChargesMap;
    }


    // Check a charge record against a list of charges for any overlaps
    // Add an error to the record if overlaps
    private void addErrorIfOverlaps(Charge__c newCharge, List<Charge__c> existingCharges) {
        for(Charge__c c : existingCharges) {

            // Continue only if charge is not being compared with itself
            if(newCharge.Id != c.Id) {

                // Check if dates overlap
                if(chargeDatesOverlap(newCharge, c)) {
                    newCharge.addError('An active charge record already exists for this account!');
                }
            }
        }
    }


    private Boolean chargeDatesOverlap(Charge__c charge1, Charge__c charge2) {
        if(charge1.Start_Date__c >= charge2.Start_Date__c && charge1.Start_Date__c < charge2.End_Date__c) {
            return true;
        }
        else if(charge1.End_Date__c > charge2.Start_Date__c && charge1.End_Date__c <= charge2.End_Date__c) {
            return true;
        }
        else {
            return false;
        }
    }
        
}
