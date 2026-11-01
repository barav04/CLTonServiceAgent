@JsonAccess(serializable='always' deserializable='always')
public with sharing class CS_CaseItem {
    @InvocableVariable(label='Case Number' description='The case number')
    @AuraEnabled
    public String caseNumber;

    @InvocableVariable(label='Subject' description='Short summary of the case')
    @AuraEnabled
    public String subject;

    @InvocableVariable(label='Status' description='Current status of the case')
    @AuraEnabled
    public String status;

    @InvocableVariable(label='Last Updated' description='When the case was last modified')
    @AuraEnabled
    public Datetime lastUpdated;

    public static CS_CaseItem fromCase(Case c) {
        CS_CaseItem item = new CS_CaseItem();
        item.caseNumber = c.CaseNumber;
        item.subject = c.Subject;
        item.status = c.Status;
        item.lastUpdated = c.LastModifiedDate;
        return item;
    }
}
