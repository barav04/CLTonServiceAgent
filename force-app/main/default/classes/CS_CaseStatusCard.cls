@JsonAccess(serializable='always' deserializable='always')
public with sharing class CS_CaseStatusCard {
    // Kept flat (no nested Apex types): Enhanced Chat v2 does not render the card when the
    // Lightning Type contains a List<ApexClass>, so the rows travel as a JSON string.
    @InvocableVariable(label='Cases JSON' description='JSON array of cases (caseNumber, subject, status, lastUpdated)')
    @AuraEnabled
    public String casesJson;

    @InvocableVariable(label='Search Term' description='Case number to prefill in the card search box')
    @AuraEnabled
    public String searchTerm;

    public static CS_CaseStatusCard of(List<CS_CaseItem> cases, String searchTerm) {
        CS_CaseStatusCard card = new CS_CaseStatusCard();
        card.casesJson = JSON.serialize(cases);
        card.searchTerm = searchTerm;
        return card;
    }
}
