import { LightningElement, api } from "lwc";

function parseJson(raw, fallback) {
  if (typeof raw !== "string" || !raw.trim()) {
    return fallback;
  }
  try {
    return JSON.parse(raw);
  } catch {
    return fallback;
  }
}

export default class MenuCard extends LightningElement {
  // Populated by the Agentforce runtime with a CS_MenuCard payload.
  // Enhanced Chat v2 can deliver it as a JSON string instead of an object.
  @api value;

  // Injected by the Enhanced Chat v2 runtime; util.sendTextMessage posts a message as the customer.
  @api configuration;

  selectedKey;
  sendError = false;

  get card() {
    const raw = this.value;
    if (raw != null && typeof raw === "object") {
      return raw;
    }
    return parseJson(raw, {}) || {};
  }

  get items() {
    const parsed = parseJson(this.card.itemsJson, []);
    return (Array.isArray(parsed) ? parsed : []).map((item, index) => {
      const key = `${index}-${item.label}`;
      return {
        key,
        label: item.label,
        icon: item.icon || "utility:chevronright",
        prompt: item.prompt || item.label,
        className:
          key === this.selectedKey
            ? "menu__topic menu__topic_selected"
            : "menu__topic"
      };
    });
  }

  get canSend() {
    return typeof this.configuration?.util?.sendTextMessage === "function";
  }

  get isDisabled() {
    return !this.canSend;
  }

  handleTopicClick(event) {
    const { key, prompt } = event.currentTarget.dataset;
    if (!this.canSend || !prompt) {
      return;
    }
    this.selectedKey = key;
    this.sendError = false;
    Promise.resolve(this.configuration.util.sendTextMessage(prompt)).catch(
      () => {
        this.selectedKey = undefined;
        this.sendError = true;
      }
    );
  }

  get assistantName() {
    return this.card.assistantName;
  }

  get tagline() {
    return this.card.tagline;
  }

  get intro() {
    return this.card.intro;
  }

  get notice() {
    return this.card.notice;
  }

  get privacyLabel() {
    return this.card.privacyLabel;
  }

  get privacyUrl() {
    return this.card.privacyUrl;
  }
}
