public with sharing class CS_GetRMAStatus {

    public class Request {
        @InvocableVariable(
            label='RMA Id'
            description='RMA identifier to look up, e.g. RMA-00001'
            required=true
        )
        public String rma_id;
    }

    public class Result {
        @InvocableVariable(
            label='RMA Id'
            description='The RMA number that was looked up'
        )
        public String rma_id;

        @InvocableVariable(
            label='RMA Status'
            description='Current status of the RMA'
        )
        public String rma_status;

        @InvocableVariable(
            label='Last Update'
            description='When the RMA was last modified'
        )
        public String last_update;
    }

    @InvocableMethod(
        label='Get RMA Status'
        description='Retrieves the status of an existing RMA by RMA number'
    )
    public static List<Result> execute(List<Request> requests) {
        Set<String> rmaNames = new Set<String>();
        for (Request req : requests) {
            if (req.rma_id != null) {
                rmaNames.add(req.rma_id.trim());
            }
        }

        Map<String, RMA__c> rmasByName = new Map<String, RMA__c>();
        if (!rmaNames.isEmpty()) {
            for (RMA__c rma : [
                SELECT Name, Status__c, LastModifiedDate
                FROM RMA__c
                WHERE Name IN :rmaNames
                WITH USER_MODE
            ]) {
                rmasByName.put(rma.Name, rma);
            }
        }

        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            RMA__c rma = req.rma_id != null ? rmasByName.get(req.rma_id.trim()) : null;
            if (rma == null) {
                r.rma_id = req.rma_id;
                r.rma_status = 'Not found';
                r.last_update = null;
            } else {
                r.rma_id = rma.Name;
                r.rma_status = rma.Status__c;
                r.last_update = rma.LastModifiedDate.format();
            }
            results.add(r);
        }
        return results;
    }
}