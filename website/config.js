// Org- and deployment-specific settings. These values come from the Embedded Service
// deployment's code snippet (Setup > Embedded Service Deployments > digi1 Web > Code Snippet).
window.DIGI1_CONFIG = {
  orgId: "00Dak00000qqW97",
  deploymentName: "digi1_Web",
  siteUrl:
    "https://personal-32e-dev-ed.develop.my.site.com/ESWdigi1Web1793472238256",
  scrt2Url: "https://personal-32e-dev-ed.develop.my.salesforce-scrt.com",
  language: "en_US",

  // Sent automatically on every page load so the conversation opens on the main menu card.
  // Set to "" to start on the landing view instead.
  autoPrompt: "main menu",
  // A message sent before the agent has joined a new conversation is not answered, and the
  // page gets no event for the join, so the automatic prompt waits this long after ready.
  autoPromptDelayMs: 6000,

  // Agent context variables sent with the first message, e.g.
  // { name: "CEC_AI_User_Type", value: { valueType: "TextValue", textValue: "Customer" } }
  // Each name must match an agent variable that has API write access.
  contextVariables: []
};
