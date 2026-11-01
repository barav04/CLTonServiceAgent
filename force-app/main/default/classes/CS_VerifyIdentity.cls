public with sharing class CS_VerifyIdentity {

    public class Request {
        @InvocableVariable(
            label='Contact Id'
            description='The contact identifier to verify against'
            required=true
        )
        public String contact_id;

        @InvocableVariable(
            label='Verification Input'
            description='Last name and mailing zip code provided by the customer, e.g. "Doe 94105"'
            required=true
        )
        public String verification_input;
    }

    public class Result {
        @InvocableVariable(
            label='Is Verified'
            description='Whether the customer identity was verified'
        )
        public Boolean is_verified;

        @InvocableVariable(
            label='Verified Name'
            description='Full name of the verified contact'
        )
        public String verified_name;
    }

    @InvocableMethod(
        label='Verify Identity'
        description='Verifies the customer identity against org records using last name and mailing zip code'
    )
    public static List<Result> execute(List<Request> requests) {
        Set<Id> contactIds = new Set<Id>();
        for (Request req : requests) {
            if (String.isNotBlank(req.contact_id)) {
                contactIds.add(Id.valueOf(req.contact_id));
            }
        }

        Map<Id, Contact> contactsById = contactIds.isEmpty()
            ? new Map<Id, Contact>()
            : new Map<Id, Contact>([
                SELECT Id, FirstName, LastName, MailingPostalCode
                FROM Contact
                WHERE Id IN :contactIds
                WITH USER_MODE
            ]);

        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            r.is_verified = false;

            Contact c = String.isNotBlank(req.contact_id) ? contactsById.get(Id.valueOf(req.contact_id)) : null;
            if (c != null && String.isNotBlank(req.verification_input)) {
                List<String> tokens = req.verification_input.trim().split('\\s+');
                if (tokens.size() >= 2) {
                    String enteredZip = tokens[tokens.size() - 1];
                    String enteredLastName = req.verification_input.substring(
                        0, req.verification_input.lastIndexOf(enteredZip)
                    ).trim();

                    Boolean lastNameMatches = c.LastName != null
                        && c.LastName.equalsIgnoreCase(enteredLastName);
                    Boolean zipMatches = c.MailingPostalCode != null
                        && c.MailingPostalCode.equalsIgnoreCase(enteredZip);

                    if (lastNameMatches && zipMatches) {
                        r.is_verified = true;
                        r.verified_name = ((c.FirstName != null ? c.FirstName + ' ' : '') + c.LastName).trim();
                    }
                }
            }

            results.add(r);
        }
        return results;
    }
}