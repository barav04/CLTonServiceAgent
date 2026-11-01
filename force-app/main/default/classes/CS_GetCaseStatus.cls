public with sharing class CS_GetCaseStatus {

    public class Request {
        @InvocableVariable(
            label='Case Id'
            description='Case number to look up, e.g. 00001234'
            required=true
        )
        public String case_id;
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class Result {
        @InvocableVariable(
            label='Case Id'
            description='The case number that was looked up'
        )
        public String case_id;

        @InvocableVariable(
            label='Case Status'
            description='Current status of the case'
        )
        public String case_status;

        @InvocableVariable(
            label='Last Update'
            description='When the case was last modified'
        )
        public String last_update;

        @InvocableVariable(
            label='Case Card'
            description='Case number, status and last update, rendered as a card'
        )
        public CS_CaseStatusCard case_card;
    }

    @InvocableMethod(
        label='Get Case Status'
        description='Retrieves the status of an existing case by case number'
    )
    public static List<Result> execute(List<Request> requests) {
        Set<String> caseNumbers = new Set<String>();
        for (Request req : requests) {
            if (req.case_id != null) {
                caseNumbers.add(req.case_id.trim());
            }
        }

        Map<String, Case> casesByNumber = new Map<String, Case>();
        if (!caseNumbers.isEmpty()) {
            for (Case c : [
                SELECT CaseNumber, Status, LastModifiedDate
                FROM Case
                WHERE CaseNumber IN :caseNumbers
                WITH USER_MODE
            ]) {
                casesByNumber.put(c.CaseNumber, c);
            }
        }

        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            Case c = req.case_id != null ? casesByNumber.get(req.case_id.trim()) : null;
            if (c == null) {
                r.case_id = req.case_id;
                r.case_status = 'Not found';
                r.last_update = null;
            } else {
                r.case_id = c.CaseNumber;
                r.case_status = c.Status;
                r.last_update = c.LastModifiedDate.format();

                CS_CaseStatusCard card = new CS_CaseStatusCard();
                card.caseNumber = c.CaseNumber;
                card.status = c.Status;
                card.lastUpdated = c.LastModifiedDate;
                r.case_card = card;
            }
            results.add(r);
        }
        return results;
    }
}