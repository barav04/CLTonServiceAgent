import { createElement } from "lwc";
import MenuCard from "c/menuCard";

const PAYLOAD = {
  assistantName: "NextGen Digital Assistant",
  tagline: "AI-based guide - understands and responds in many languages",
  intro: "I can help you with these topics and more:",
  itemsJson: JSON.stringify([
    { label: "Software Downloads", icon: "utility:download" },
    { label: "RMA Assistance", icon: "utility:refresh" }
  ]),
  notice:
    "Any conversation will be monitored and recorded. Any information shared is subject to our",
  privacyLabel: "Privacy Notice",
  privacyUrl: "https://www.juniper.net/us/en/privacy-policy.html"
};

describe("c-menu-card", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it.each([
    ["an object", PAYLOAD],
    ["a JSON string", JSON.stringify(PAYLOAD)]
  ])("renders title, topics and privacy link from %s", (_, value) => {
    const el = createElement("c-menu-card", { is: MenuCard });
    el.value = value;
    document.body.appendChild(el);

    const root = el.shadowRoot;
    expect(root.querySelector(".menu__title").textContent).toBe(
      "NextGen Digital Assistant"
    );
    expect(root.querySelectorAll(".menu__topic")).toHaveLength(2);
    expect(root.querySelector(".menu__link").href).toBe(PAYLOAD.privacyUrl);
  });

  it("renders without a value", () => {
    const el = createElement("c-menu-card", { is: MenuCard });
    document.body.appendChild(el);
    expect(el.shadowRoot.querySelectorAll(".menu__topic")).toHaveLength(0);
  });
});
