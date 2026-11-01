@JsonAccess(serializable='always' deserializable='always')
public with sharing class CS_MenuCard {
  // Kept flat (strings only): Enhanced Chat v2 does not render the card when the
  // Lightning Type contains a List<ApexClass>, so the menu items travel as a JSON string.
  // Avoid JSON Schema keywords (title, description, type...) as property names: Enhanced Chat
  // reports "There was a problem rendering" when the type has a property called title.
  @InvocableVariable(
    label='Assistant Name'
    description='Assistant name shown in the card header'
  )
  @AuraEnabled
  public String assistantName;

  @InvocableVariable(
    label='Tagline'
    description='Short line under the assistant name'
  )
  @AuraEnabled
  public String tagline;

  @InvocableVariable(
    label='Intro'
    description='Line shown above the menu items'
  )
  @AuraEnabled
  public String intro;

  @InvocableVariable(
    label='Items JSON'
    description='JSON array of menu items (label, icon)'
  )
  @AuraEnabled
  public String itemsJson;

  @InvocableVariable(
    label='Notice'
    description='Monitoring notice shown in the card footer'
  )
  @AuraEnabled
  public String notice;

  @InvocableVariable(
    label='Privacy Label'
    description='Link text for the privacy notice'
  )
  @AuraEnabled
  public String privacyLabel;

  @InvocableVariable(
    label='Privacy URL'
    description='URL of the privacy notice'
  )
  @AuraEnabled
  public String privacyUrl;
}
