import { createElement } from "lwc";
import MenuCard from "c/menuCard";

const PAYLOAD = {
  assistantName: "NextGen Digital Assistant",
  tagline: "AI-based guide - understands and responds in many languages",
  intro: "I can help you with these topics and more:",
  itemsJson: JSON.stringify([
    {
      label: "Software Downloads",
      icon: "utility:download",
      prompt: "I need help with software downloads"
    },
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

  function renderWithConfiguration(sendTextMessage) {
    const el = createElement("c-menu-card", { is: MenuCard });
    el.value = PAYLOAD;
    el.configuration = { util: { sendTextMessage } };
    document.body.appendChild(el);
    return el;
  }

  it("sends the topic prompt as a message when a topic is clicked", async () => {
    const sendTextMessage = jest.fn().mockResolvedValue(undefined);
    const el = renderWithConfiguration(sendTextMessage);

    const [downloads, rma] = el.shadowRoot.querySelectorAll(".menu__topic");
    downloads.click();
    rma.click();
    await Promise.resolve();

    expect(sendTextMessage).toHaveBeenNthCalledWith(
      1,
      "I need help with software downloads"
    );
    // Falls back to the label when an item has no prompt.
    expect(sendTextMessage).toHaveBeenNthCalledWith(2, "RMA Assistance");
    expect(rma.classList).toContain("menu__topic_selected");
  });

  it("shows an error when sending fails", async () => {
    const el = renderWithConfiguration(
      jest.fn().mockRejectedValue(new Error("offline"))
    );

    el.shadowRoot.querySelector(".menu__topic").click();
    // Let the rejected promise's catch handler run and the template re-render.
    for (let i = 0; i < 3; i++) {
      // eslint-disable-next-line no-await-in-loop
      await Promise.resolve();
    }

    expect(el.shadowRoot.querySelector(".menu__error")).not.toBeNull();
  });

  it("disables topics when the chat runtime is not available", () => {
    const el = createElement("c-menu-card", { is: MenuCard });
    el.value = PAYLOAD;
    document.body.appendChild(el);

    const topic = el.shadowRoot.querySelector(".menu__topic");
    expect(topic.disabled).toBe(true);
  });
});
