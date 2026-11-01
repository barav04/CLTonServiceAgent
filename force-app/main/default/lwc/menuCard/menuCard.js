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

  get card() {
    const raw = this.value;
    if (raw != null && typeof raw === "object") {
      return raw;
    }
    return parseJson(raw, {}) || {};
  }

  get items() {
    const parsed = parseJson(this.card.itemsJson, []);
    return (Array.isArray(parsed) ? parsed : []).map((item, index) => ({
      key: `${index}-${item.label}`,
      label: item.label,
      icon: item.icon || "utility:chevronright"
    }));
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
