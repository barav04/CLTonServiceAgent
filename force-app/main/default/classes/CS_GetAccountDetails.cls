public with sharing class CS_GetAccountDetails {

    public class Request {
        @InvocableVariable(
            label='Contact Id'
            description='The contact identifier for the account'
            required=true
        )
        public String contact_id;
    }

    public class Result {
        @InvocableVariable(
            label='Account Name'
            description='Name of the account the contact belongs to'
        )
        public String account_name;

        @InvocableVariable(
            label='Email Address'
            description='Email address on file for the contact'
        )
        public String email_address;

        @InvocableVariable(
            label='Mailing Address'
            description='Mailing address on file for the contact'
        )
        public String mailing_address;

        @InvocableVariable(
            label='Plan Name'
            description='Name of the plan the contact is subscribed to'
        )
        public String plan_name;
    }

    @InvocableMethod(
        label='Get Account Details'
        description='Retrieves account and profile details for a contact'
    )
    public static List<Result> execute(List<Request> requests) {
        Set<Id> contactIds = new Set<Id>();
        for (Request req : requests) {
            if (String.isNotBlank(req.contact_id)) {
                contactIds.add(Id.valueOf(req.contact_id));
            }
        }

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        if (!contactIds.isEmpty()) {
            contactsById = new Map<Id, Contact>([
                SELECT Account.Name, Email, MailingStreet, MailingCity, MailingState,
                       MailingPostalCode, MailingCountry, Plan_Name__c
                FROM Contact
                WHERE Id IN :contactIds
                WITH USER_MODE
            ]);
        }

        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            Contact c = String.isNotBlank(req.contact_id) ? contactsById.get(Id.valueOf(req.contact_id)) : null;
            if (c == null) {
                r.account_name = null;
                r.email_address = null;
                r.mailing_address = null;
                r.plan_name = null;
            } else {
                r.account_name = c.Account != null ? c.Account.Name : null;
                r.email_address = c.Email;
                r.mailing_address = formatAddress(c);
                r.plan_name = c.Plan_Name__c;
            }
            results.add(r);
        }
        return results;
    }

    private static String formatAddress(Contact c) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(c.MailingStreet)) parts.add(c.MailingStreet);
        if (String.isNotBlank(c.MailingCity)) parts.add(c.MailingCity);
        if (String.isNotBlank(c.MailingState)) parts.add(c.MailingState);
        if (String.isNotBlank(c.MailingPostalCode)) parts.add(c.MailingPostalCode);
        if (String.isNotBlank(c.MailingCountry)) parts.add(c.MailingCountry);
        return parts.isEmpty() ? null : String.join(parts, ', ');
    }
}