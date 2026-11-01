public with sharing class CS_AddCaseNote {

    public class Request {
        @InvocableVariable(
            label='Case Id'
            description='Case number to add the note to, e.g. 00001234'
            required=true
        )
        public String case_id;

        @InvocableVariable(
            label='Note Text'
            description='The note content to add'
            required=true
        )
        public String note_text;
    }

    public class Result {
        @InvocableVariable(
            label='Note Confirmation'
            description='Confirmation message describing the outcome'
        )
        public String note_confirmation;
    }

    @InvocableMethod(
        label='Add Case Note'
        description='Adds a note to an existing case'
    )
    public static List<Result> execute(List<Request> requests) {
        Set<String> caseNumbers = new Set<String>();
        for (Request req : requests) {
            if (req.case_id != null) {
                caseNumbers.add(req.case_id.trim());
            }
        }

        Map<String, Id> caseIdByNumber = new Map<String, Id>();
        if (!caseNumbers.isEmpty()) {
            for (Case c : [SELECT Id, CaseNumber FROM Case WHERE CaseNumber IN :caseNumbers WITH USER_MODE]) {
                caseIdByNumber.put(c.CaseNumber, c.Id);
            }
        }

        List<CaseComment> commentsToInsert = new List<CaseComment>();
        List<Result> results = new List<Result>();
        List<Integer> resultIndexForComment = new List<Integer>();

        for (Request req : requests) {
            Id caseId = req.case_id != null ? caseIdByNumber.get(req.case_id.trim()) : null;
            Result r = new Result();
            results.add(r);
            if (caseId == null) {
                r.note_confirmation = 'Case not found: ' + req.case_id;
            } else {
                commentsToInsert.add(new CaseComment(ParentId = caseId, CommentBody = req.note_text));
                resultIndexForComment.add(results.size() - 1);
            }
        }

        if (!commentsToInsert.isEmpty()) {
            Database.SaveResult[] saveResults = Database.insert(commentsToInsert, false, AccessLevel.USER_MODE);
            for (Integer i = 0; i < saveResults.size(); i++) {
                Result r = results[resultIndexForComment[i]];
                r.note_confirmation = saveResults[i].isSuccess()
                    ? 'Note added successfully.'
                    : 'Failed to add note: ' + saveResults[i].getErrors()[0].getMessage();
            }
        }

        return results;
    }
}