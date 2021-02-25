public class CreateContactExtension {
    public Contact contact1 {get; set;}
    public String relWithCompany {get; set;}
    Private final Account accountPage;
    
    
    public CreateContactExtension(ApexPages.StandardController stdController){
        this.accountPage = (Account)stdController.getRecord();
        contact1 = new Contact(AccountID = this.accountPage.Id, WAW_Affiliation_with_Company__c = 'Employee', RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WAW Client').getRecordTypeId());
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'This page SHOULD NOT be used to refer past or current Insight clients. To rerefer a client, use the \'Search Salesforce\' search box'));
        
    }
    
    public PageReference insertContact(){
        try{
            insert(contact1);
            return new PageReference('/' + contact1.Id);
        }catch(System.DmlException e){
            ApexPages.Message msg = new apexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0));
            if(e.getDmlMessage(0).contains('Use one of these records?')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You are attempting to create a duplicate record! Please search for this client in the \'Search Salesforce\' box'));
            }else{
                ApexPages.addMessage(msg);
            }
            
            return null;
        }
        
        
        
    }
  
    
    
    
}