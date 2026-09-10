import getRecentNotifications from "@salesforce/apex/PWChrono_NotificationController.getRecentNotifications";
import markAllAsRead from "@salesforce/apex/PWChrono_NotificationController.markAllAsRead";
import markAsRead from "@salesforce/apex/PWChrono_NotificationController.markAsRead";
import { getSession, clearSession } from "c/pwchronoSession";
jest.mock(
  "@salesforce/apex/PWChrono_NotificationController.getRecentNotifications",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_NotificationController.markAsRead",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_NotificationController.markAllAsRead",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
const flush = async () => {
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
};
import { createElement } from "lwc";
import PwchronoHeader from "c/pwchronoHeader";

jest.mock("c/pwchronoSession", () => ({
  getSession: jest.fn(() => ({ isLoggedIn: false })),
  clearSession: jest.fn(),
  SESSION_CHANGED_EVENT: "pwchrono-session-changed"
}));

describe("PWChrono SmartHR header", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    getSession.mockReturnValue({ isLoggedIn: false });
    getRecentNotifications.mockResolvedValue([]);
    markAllAsRead.mockResolvedValue();
    markAsRead.mockResolvedValue();
  });
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
      "Find a page"
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

  it("emits search on input and leaves logout credentials for server revocation", () => {
    const element = mount();
    const search = jest.fn();
    const logout = jest.fn();
    element.addEventListener("search", search);
    element.addEventListener("logout", logout);
    const input = element.querySelector("input");
    input.value = "leave";
    input.dispatchEvent(new CustomEvent("input"));
    expect(search.mock.calls[0][0].detail.searchTerm).toBe("leave");
    element.querySelector('[data-action="toggleProfileMenu"]').click();
    return flush().then(() => {
      element.querySelector('[data-action="logout"]').click();
      expect(logout).toHaveBeenCalledTimes(1);
      expect(clearSession).not.toHaveBeenCalled();
    });
  });
  it("loads real notifications, expands the list, and authenticates read updates", async () => {
    getSession.mockReturnValue({
      isLoggedIn: true,
      user: { Id: "employee" },
      sessionToken: "token"
    });
    getRecentNotifications.mockResolvedValue(
      Array.from({ length: 7 }, (_, i) => ({
        Id: String(i),
        Subject: "Notice " + i,
        Message: "Message",
        IsRead: false
      }))
    );
    const element = mount();
    await flush();
    element.querySelector('[data-action="toggleNotifications"]').click();
    await flush();
    expect(getRecentNotifications).toHaveBeenCalledWith({
      portalUserId: "employee",
      sessionToken: "token"
    });
    expect(element.querySelectorAll("[data-id]")).toHaveLength(5);
    const showAll = Array.from(element.querySelectorAll("button")).find(
      (button) => button.textContent.includes("Show all recent")
    );
    showAll.click();
    await flush();
    expect(element.querySelectorAll("[data-id]")).toHaveLength(7);
    element.querySelector('[data-id="0"]').click();
    await flush();
    expect(markAsRead).toHaveBeenCalledWith({
      portalUserId: "employee",
      sessionToken: "token",
      notificationId: "0"
    });
    const markAll = Array.from(element.querySelectorAll("button")).find(
      (button) => button.textContent.includes("Mark All Read")
    );
    getRecentNotifications.mockResolvedValue([]);
    markAll.click();
    await flush();
    expect(markAllAsRead).toHaveBeenCalledWith({
      portalUserId: "employee",
      sessionToken: "token"
    });
    expect(element.textContent).toContain("No notifications yet.");
  });
  it("shows notification errors without pretending there are no notifications", async () => {
    getSession.mockReturnValue({
      isLoggedIn: true,
      user: { Id: "employee" },
      sessionToken: "token"
    });
    getRecentNotifications.mockRejectedValue({
      body: { message: "Service unavailable" }
    });
    const element = mount();
    await flush();
    element.querySelector('[data-action="toggleNotifications"]').click();
    await flush();
    expect(element.querySelector('[role="alert"]').textContent).toBe(
      "Service unavailable"
    );
    expect(element.textContent).not.toContain("No notifications yet.");
  });
});
