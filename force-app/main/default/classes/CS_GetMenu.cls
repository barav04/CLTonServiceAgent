public with sharing class CS_GetMenu {
  private static final List<Map<String, String>> MENU_ITEMS = new List<Map<String, String>>{
    new Map<String, String>{
      'label' => 'Software Downloads',
      'icon' => 'utility:download'
    },
    new Map<String, String>{
      'label' => 'RMA Assistance',
      'icon' => 'utility:refresh'
    },
    new Map<String, String>{
      'label' => 'License Assistance',
      'icon' => 'utility:lock'
    },
    new Map<String, String>{
      'label' => 'Asset Information',
      'icon' => 'utility:apps'
    },
    new Map<String, String>{
      'label' => 'Account Assistance',
      'icon' => 'utility:user'
    },
    new Map<String, String>{
      'label' => 'Case Assistance',
      'icon' => 'utility:case'
    },
    new Map<String, String>{
      'label' => 'Knowledge Search',
      'icon' => 'utility:knowledge_base'
    },
    new Map<String, String>{
      'label' => 'Service Contract',
      'icon' => 'utility:file'
    }
  };

  public class Request {
    @InvocableVariable(
      label='Reason'
      description='Optional reason the menu is shown, e.g. greeting or help request'
    )
    public String reason;
  }

  @JsonAccess(serializable='always' deserializable='always')
  public class Result {
    @InvocableVariable(
      label='Menu Card'
      description='Welcome menu of supported topics, rendered as a card'
    )
    public CS_MenuCard menu_card;
  }

  @InvocableMethod(
    label='Get Menu'
    description='Returns the welcome menu of topics the assistant can help with'
  )
  public static List<Result> execute(List<Request> requests) {
    List<Result> results = new List<Result>();
    for (Request req : requests) {
      Result r = new Result();
      r.menu_card = buildMenu();
      results.add(r);
    }
    return results;
  }

  private static CS_MenuCard buildMenu() {
    CS_MenuCard card = new CS_MenuCard();
    card.assistantName = 'NextGen Digital Assistant';
    card.tagline = 'AI-based guide - understands and responds in many languages';
    card.intro = 'I can help you with these topics and more:';
    card.itemsJson = JSON.serialize(MENU_ITEMS);
    card.notice = 'Any conversation will be monitored and recorded. Any information shared is subject to our';
    card.privacyLabel = 'Privacy Notice';
    card.privacyUrl = 'https://www.juniper.net/us/en/privacy-policy.html';
    return card;
  }
}
