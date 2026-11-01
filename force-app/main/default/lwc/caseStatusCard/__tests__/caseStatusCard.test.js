import { createElement } from "lwc";
import CaseStatusCard from "c/caseStatusCard";

const CASES = Array.from({ length: 7 }, (_, i) => ({
  caseNumber: `0000100${i}`,
  subject: `Subject ${i}`,
  status: "New",
  lastUpdated: "2026-10-31T18:26:51.000Z"
}));

function render(cases, configuration) {
  const el = createElement("c-case-status-card", { is: CaseStatusCard });
  el.value = { casesJson: JSON.stringify(cases) };
  if (configuration) {
    el.configuration = configuration;
  }
  document.body.appendChild(el);
  return el;
}

async function flush() {
  for (let i = 0; i < 3; i++) {
    // eslint-disable-next-line no-await-in-loop
    await Promise.resolve();
  }
}

function selectButtons(el) {
  return [...el.shadowRoot.querySelectorAll("lightning-button")].filter(
    (b) => b.value
  );
}

describe("c-case-status-card", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("shows 5 cases per page with a Select button on each", () => {
    const el = render(CASES, { util: { sendTextMessage: jest.fn() } });
    expect(el.shadowRoot.querySelectorAll("li")).toHaveLength(5);
    expect(selectButtons(el)).toHaveLength(5);
  });

  it("sends the selected case as a message and marks it selected", async () => {
    const sendTextMessage = jest.fn().mockResolvedValue(undefined);
    const el = render(CASES, { util: { sendTextMessage } });

    const button = selectButtons(el)[1];
    button.click();
    await flush();

    expect(sendTextMessage).toHaveBeenCalledWith(
      "I want to continue with case 00001001"
    );
    expect(selectButtons(el)[1].label).toBe("Selected");
    expect(el.shadowRoot.querySelectorAll("li")[1].classList).toContain(
      "case-row_selected"
    );

    // Clicking the already selected case does not send again.
    selectButtons(el)[1].click();
    expect(sendTextMessage).toHaveBeenCalledTimes(1);
  });

  it("shows an error and clears the selection when sending fails", async () => {
    const el = render(CASES, {
      util: { sendTextMessage: jest.fn().mockRejectedValue(new Error("x")) }
    });

    selectButtons(el)[0].click();
    await flush();

    expect(
      el.shadowRoot.querySelector(".slds-text-color_error")
    ).not.toBeNull();
    expect(selectButtons(el)[0].label).toBe("Select");
  });

  it("disables Select when the chat runtime is not available", () => {
    const el = render(CASES);
    expect(selectButtons(el).every((b) => b.disabled)).toBe(true);
  });

  it("hides Select for a single-case card", () => {
    const el = render(CASES.slice(0, 1), {
      util: { sendTextMessage: jest.fn() }
    });
    expect(selectButtons(el)).toHaveLength(0);
  });
});
