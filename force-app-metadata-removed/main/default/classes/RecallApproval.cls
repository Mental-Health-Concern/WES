public class RecallApproval {

    @InvocableMethod(label='RecallApproval')

    public static void RecallApproval1(List<id> recId){
        try{
            ProcessInstanceWorkitem[] workItems = [ SELECT Id

                FROM ProcessInstanceWorkitem

                WHERE ProcessInstance.TargetObjectId = :recId ];

            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest(); 

            pwr.setAction('Removed');

            pwr.setWorkItemId(workItems[0].id);

           

            Approval.ProcessResult result = Approval.process(pwr);
            
            
        }catch(Exception ex){
            system.debug('Fail! No Approvals found!');
        }
            

    }

}