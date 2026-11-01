@JsonAccess(serializable='always' deserializable='always')
public with sharing class CS_CaseStatusCard {

    @InvocableVariable(label='Case Number' description='The case number')
    @AuraEnabled
    public String caseNumber;

    @InvocableVariable(label='Status' description='Current status of the case')
    @AuraEnabled
    public String status;

    @InvocableVariable(label='Last Updated' description='When the case was last modified')
    @AuraEnabled
    public Datetime lastUpdated;
}
