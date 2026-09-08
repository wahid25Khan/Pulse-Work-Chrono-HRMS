import { createElement } from "lwc";
import PwchronoHeader from "c/pwchronoHeader";

jest.mock("c/pwchronoSession", () => ({
  getSession: jest.fn(() => ({ isLoggedIn: false })),
  clearSession: jest.fn(),
  SESSION_CHANGED_EVENT: "pwchrono-session-changed"
}));

describe("PWChrono SmartHR header", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  function mount(properties = {}) {
    const element = createElement("c-pwchrono-header", {
      is: PwchronoHeader
    });
    Object.assign(element, properties);
    document.body.appendChild(element);
    return element;
  }

  it("renders brand initials when no logo was configured", () => {
    const element = mount();
    expect(element.querySelector(".logo img")).toBeNull();
    expect(element.querySelector(".logo-fallback").textContent).toBe("PW");
    expect(element.querySelector("input").getAttribute("aria-label")).toBe(
      "Search in HRMS"
    );
  });

  it("falls back after a configured logo fails without losing the home link", async () => {
    const element = mount({ logoLightUrl: "/brand.svg" });
    const homeLink = element.querySelector(".logo").getAttribute("href");
    // Simulate the browser's native image-load error, not an application event.
    // eslint-disable-next-line @lwc/lwc/prefer-custom-event
    element.querySelector(".logo img").dispatchEvent(new Event("error"));
    await Promise.resolve();
    expect(element.querySelector(".logo img")).toBeNull();
    expect(element.querySelector(".logo-fallback")).not.toBeNull();
    expect(element.querySelector(".logo").getAttribute("href")).toBe(homeLink);
  });

  it("preserves the desktop sidebar action", () => {
    const element = mount();
    const onToggle = jest.fn();
    element.addEventListener("togglesidebar", onToggle);
    element.querySelector('[data-action="toggleSidebar"]').click();
    expect(onToggle).toHaveBeenCalledTimes(1);
    expect(onToggle.mock.calls[0][0].detail.mode).toBe("toggle");
  });
});
