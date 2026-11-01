public with sharing class CS_UpdateAccountDetails {

    public class Request {
        @InvocableVariable(
            label='Contact Id'
            description='The contact identifier for the account'
            required=true
        )
        public String contact_id;

        @InvocableVariable(
            label='Field Name'
            description='Which field to update: email, address, or plan'
            required=true
        )
        public String field_name;

        @InvocableVariable(
            label='New Value'
            description='The new value for the field'
            required=true
        )
        public String new_value;
    }

    public class Result {
        @InvocableVariable(
            label='Update Confirmation'
            description='Confirmation message describing the outcome'
        )
        public String update_confirmation;

        @InvocableVariable(
            label='Updated Value'
            description='The value the field was updated to'
        )
        public String updated_value;
    }

    @InvocableMethod(
        label='Update Account Details'
        description='Updates a single field on the customer account: email, address, or plan'
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
                SELECT Id, Email, MailingStreet, Plan_Name__c
                FROM Contact
                WHERE Id IN :contactIds
                WITH USER_MODE
            ]);

        List<Contact> contactsToUpdate = new List<Contact>();
        List<Result> results = new List<Result>();
        List<Integer> resultIndexForUpdate = new List<Integer>();

        for (Request req : requests) {
            Result r = new Result();
            results.add(r);

            Contact c = String.isNotBlank(req.contact_id) ? contactsById.get(Id.valueOf(req.contact_id)) : null;
            if (c == null) {
                r.update_confirmation = 'Contact not found: ' + req.contact_id;
                continue;
            }

            String field = req.field_name != null ? req.field_name.trim().toLowerCase() : '';
            Contact contactUpdate = new Contact(Id = c.Id);
            if (field == 'email') {
                contactUpdate.Email = req.new_value;
            } else if (field == 'address' || field == 'mailing_address') {
                contactUpdate.MailingStreet = req.new_value;
            } else if (field == 'plan' || field == 'plan_name') {
                contactUpdate.Plan_Name__c = req.new_value;
            } else {
                r.update_confirmation = 'Unsupported field: ' + req.field_name;
                continue;
            }

            contactsToUpdate.add(contactUpdate);
            resultIndexForUpdate.add(results.size() - 1);
        }

        if (!contactsToUpdate.isEmpty()) {
            Database.SaveResult[] saveResults = Database.update(contactsToUpdate, false, AccessLevel.USER_MODE);
            for (Integer i = 0; i < saveResults.size(); i++) {
                Result r = results[resultIndexForUpdate[i]];
                if (saveResults[i].isSuccess()) {
                    r.update_confirmation = 'Account updated successfully.';
                    r.updated_value = requests[resultIndexForUpdate[i]].new_value;
                } else {
                    r.update_confirmation = 'Failed to update: ' + saveResults[i].getErrors()[0].getMessage();
                }
            }
        }

        return results;
    }
}