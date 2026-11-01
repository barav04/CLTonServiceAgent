public with sharing class CS_CreateSupportCase {

    public class Request {
        @InvocableVariable(
            label='Subject'
            description='Short summary of the customer issue'
            required=true
        )
        public String subject;

        @InvocableVariable(
            label='Case Detail'
            description='Full description of the issue'
            required=true
        )
        public String case_detail;
    }

    public class Result {
        @InvocableVariable(
            label='Case Id'
            description='The created case number, e.g. 00001234'
        )
        public String case_id;

        @InvocableVariable(
            label='Case Status'
            description='Status of the newly created case'
        )
        public String case_status;
    }

    @InvocableMethod(
        label='Create Support Case'
        description='Creates a new support case for the customer'
    )
    public static List<Result> execute(List<Request> requests) {
        List<Case> casesToInsert = new List<Case>();
        for (Request req : requests) {
            casesToInsert.add(new Case(
                Subject = req.subject,
                Description = req.case_detail,
                Status = 'New',
                Origin = 'Chat'
            ));
        }

        Database.SaveResult[] saveResults = Database.insert(casesToInsert, false, AccessLevel.USER_MODE);

        Set<Id> insertedIds = new Set<Id>();
        for (Case c : casesToInsert) {
            if (c.Id != null) {
                insertedIds.add(c.Id);
            }
        }
        Map<Id, Case> insertedById = insertedIds.isEmpty()
            ? new Map<Id, Case>()
            : new Map<Id, Case>([SELECT Id, CaseNumber, Status FROM Case WHERE Id IN :insertedIds WITH USER_MODE]);

        List<Result> results = new List<Result>();
        for (Integer i = 0; i < saveResults.size(); i++) {
            Result r = new Result();
            Case createdCase = casesToInsert[i].Id != null ? insertedById.get(casesToInsert[i].Id) : null;
            if (saveResults[i].isSuccess() && createdCase != null) {
                r.case_id = createdCase.CaseNumber;
                r.case_status = createdCase.Status;
            } else {
                r.case_id = null;
                r.case_status = 'Error: ' + saveResults[i].getErrors()[0].getMessage();
            }
            results.add(r);
        }
        return results;
    }
}