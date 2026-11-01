public with sharing class CS_CreateRMA {

    public class Request {
        @InvocableVariable(
            label='Order Id'
            description='Order identifier the return is for'
            required=true
        )
        public String order_id;

        @InvocableVariable(
            label='Return Reason'
            description='Why the customer is returning the item'
            required=true
        )
        public String return_reason;
    }

    public class Result {
        @InvocableVariable(
            label='RMA Id'
            description='The generated RMA number, e.g. RMA-00001'
        )
        public String rma_id;

        @InvocableVariable(
            label='RMA Status'
            description='Status of the newly created RMA'
        )
        public String rma_status;

        @InvocableVariable(
            label='Return Label URL'
            description='Link to the printable return shipping label'
        )
        public String return_label_url;
    }

    @InvocableMethod(
        label='Create RMA'
        description='Creates a return and generates an RMA number'
    )
    public static List<Result> execute(List<Request> requests) {
        List<RMA__c> rmasToInsert = new List<RMA__c>();
        for (Request req : requests) {
            rmasToInsert.add(new RMA__c(
                Order_Id__c = req.order_id,
                Return_Reason__c = req.return_reason,
                Status__c = 'New',
                Return_Label_URL__c = 'https://returns.example.com/labels/' + req.order_id
            ));
        }

        Database.SaveResult[] saveResults = Database.insert(rmasToInsert, false, AccessLevel.USER_MODE);

        List<Result> results = new List<Result>();
        for (Integer i = 0; i < saveResults.size(); i++) {
            Result r = new Result();
            if (!saveResults[i].isSuccess()) {
                r.rma_id = null;
                r.rma_status = 'Error: ' + saveResults[i].getErrors()[0].getMessage();
            }
            results.add(r);
        }

        Set<Id> insertedIds = new Set<Id>();
        for (RMA__c rma : rmasToInsert) {
            if (rma.Id != null) {
                insertedIds.add(rma.Id);
            }
        }
        Map<Id, RMA__c> withNames = insertedIds.isEmpty()
            ? new Map<Id, RMA__c>()
            : new Map<Id, RMA__c>([SELECT Id, Name, Status__c, Return_Label_URL__c FROM RMA__c WHERE Id IN :insertedIds WITH USER_MODE]);

        for (Integer i = 0; i < rmasToInsert.size(); i++) {
            RMA__c rma = rmasToInsert[i];
            if (rma.Id != null && withNames.containsKey(rma.Id)) {
                RMA__c created = withNames.get(rma.Id);
                results[i].rma_id = created.Name;
                results[i].rma_status = created.Status__c;
                results[i].return_label_url = created.Return_Label_URL__c;
            }
        }

        return results;
    }
}