public with sharing class CS_ListCases {

    // Upper bound on rows sent to the card; the LWC pages through them 5 at a time.
    private static final Integer MAX_CASES = 200;

    public class Request {
        @InvocableVariable(
            label='Search Term'
            description='Optional case number to prefill in the card search box'
        )
        public String search_term;
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class Result {
        @InvocableVariable(
            label='Total Cases'
            description='Number of cases returned'
        )
        public Integer total_cases;

        @InvocableVariable(
            label='Case List Card'
            description='All available cases, rendered as a searchable, paginated card'
        )
        public CS_CaseStatusCard case_card;
    }

    @InvocableMethod(
        label='List Cases'
        description='Retrieves all available cases, most recently updated first'
    )
    public static List<Result> execute(List<Request> requests) {
        List<CS_CaseItem> items = new List<CS_CaseItem>();
        for (Case c : [
            SELECT CaseNumber, Subject, Status, LastModifiedDate
            FROM Case
            WITH USER_MODE
            ORDER BY LastModifiedDate DESC
            LIMIT :MAX_CASES
        ]) {
            items.add(CS_CaseItem.fromCase(c));
        }

        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            r.total_cases = items.size();
            r.case_card = CS_CaseStatusCard.of(
                items,
                String.isBlank(req.search_term) ? null : req.search_term.trim()
            );
            results.add(r);
        }
        return results;
    }
}
