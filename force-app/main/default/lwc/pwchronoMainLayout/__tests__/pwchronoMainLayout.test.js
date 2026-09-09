import { createElement } from "lwc";
import MainLayout from "c/pwchronoMainLayout";
import getAccess from "@salesforce/apex/PWChrono_AccessController.getUserAccessById";
import getContext from "@salesforce/apex/PWChrono_AuthController.getCurrentUserContext";
import { setSession, getSession, clearSession } from "c/pwchronoSession";

jest.mock(
  "@salesforce/apex/PWChrono_AccessController.getUserAccessById",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_AuthController.getCurrentUserContext",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

jest.mock("c/pwchronoSidebar", () => {
  const { LightningElement, registerDecorators } = require("lwc");
  class Sidebar extends LightningElement {}
  registerDecorators(Sidebar, {
    publicProps: {
      features: { config: 0 },
      isSalesforceUser: { config: 0 },
      applicationMode: { config: 0 },
      navigationContext: { config: 0 }
    }
  });
  return { __esModule: true, default: Sidebar };
});
jest.mock("c/pwchronoHeader", () => {
  const { LightningElement } = require("lwc");
  return {
    __esModule: true,
    default: class Header extends LightningElement {}
  };
});
jest.mock("c/pwchronoUiAssets", () => {
  const { LightningElement } = require("lwc");
  return {
    __esModule: true,
    default: class Assets extends LightningElement {}
  };
});

const flush = async () => {
  // Drain the nested authentication promises without advancing the expiry clock.
  // eslint-disable-next-line no-await-in-loop
  for (let i = 0; i < 12; i++) await Promise.resolve();
};
let replace;
const originalLocation = window.location;

function login(expiresIn = 120000, token = "test-token") {
  setSession(
    {
      Id: "employee",
      Session_Expires_At__c: new Date(Date.now() + expiresIn).toISOString()
    },
    {},
    token
  );
}
function mount(path = "/PulseWorkChrono/dashboard") {
  delete window.location;
  window.location = { pathname: path, replace, origin: "https://example.test" };
  const element = createElement("c-pwchrono-main-layout", { is: MainLayout });
  document.body.appendChild(element);
  return element;
}

beforeEach(() => {
  jest.useFakeTimers();
  jest.clearAllMocks();
  replace = jest.fn();
  getAccess.mockResolvedValue({ hasAccess: true, features: [] });
  getContext.mockResolvedValue(null);
  login();
});
afterEach(() => {
  while (document.body.firstChild) document.body.firstChild.remove();
  clearSession();
  jest.clearAllTimers();
  jest.useRealTimers();
  window.location = originalLocation;
});

it("automatically clears an idle expired session and navigates to login", async () => {
  login(1000);
  mount();
  await flush();
  expect(replace).not.toHaveBeenCalled();
  jest.advanceTimersByTime(1000);
  await flush();
  expect(replace).toHaveBeenCalledWith("/PulseWorkChrono/login");
  expect(getSession().isLoggedIn).toBe(false);
});

it("redirects an already expired session before making an access request", async () => {
  login(-1);
  mount("/community/s/home");
  await flush();
  expect(replace).toHaveBeenCalledWith("/community/s/login");
  expect(getAccess).not.toHaveBeenCalled();
});

it("detects server revocation on its periodic check", async () => {
  mount();
  await flush();
  getAccess.mockRejectedValue({
    body: { message: "Session invalid. Please log in again." }
  });
  jest.advanceTimersByTime(60000);
  await flush();
  expect(replace).toHaveBeenCalledWith("/PulseWorkChrono/login");
  expect(getSession().sessionToken).toBeNull();
});

it("keeps the session during network failures and retries", async () => {
  getAccess.mockRejectedValue({ body: { message: "Network unavailable" } });
  mount();
  await flush();
  jest.advanceTimersByTime(60000);
  await flush();
  expect(replace).not.toHaveBeenCalled();
  expect(getAccess).toHaveBeenCalledTimes(2);
  expect(getSession().isLoggedIn).toBe(true);
});

it("checks removed storage on tab focus without restoring stale memory", async () => {
  mount();
  await flush();
  sessionStorage.clear();
  window.dispatchEvent(new CustomEvent("focus"));
  await flush();
  expect(replace).toHaveBeenCalledWith("/PulseWorkChrono/login");
});

it("ignores a failed check for a replaced session", async () => {
  let rejectOld;
  getAccess.mockImplementationOnce(
    () =>
      new Promise((resolve, reject) => {
        rejectOld = reject;
      })
  );
  mount();
  await flush();
  login(120000, "new-token");
  rejectOld({ body: { message: "Session expired. Please log in again." } });
  await flush();
  expect(replace).not.toHaveBeenCalled();
  expect(getSession().sessionToken).toBe("new-token");
});

it.each([
  "/PulseWorkChrono/login",
  "/lightning/setup/Builder",
  "/lightning/page/home"
])("does not redirect or poll in %s", async (path) => {
  login(-1);
  mount(path);
  await flush();
  jest.advanceTimersByTime(120000);
  await flush();
  expect(replace).not.toHaveBeenCalled();
  expect(getAccess.mock.calls.length).toBeLessThanOrEqual(1);
});

it("stops monitoring when disconnected", async () => {
  const element = mount();
  await flush();
  element.remove();
  jest.advanceTimersByTime(120000);
  window.dispatchEvent(new CustomEvent("focus"));
  await flush();
  expect(getAccess).toHaveBeenCalledTimes(1);
  expect(replace).not.toHaveBeenCalled();
});

it("redirects if only the OTP session token is removed", async () => {
  mount();
  await flush();
  sessionStorage.removeItem("portalSessionToken");
  window.dispatchEvent(new CustomEvent("focus"));
  await flush();
  expect(replace).toHaveBeenCalledWith("/PulseWorkChrono/login");
});

it("does not reuse an OTP token for a native Salesforce session", () => {
  setSession({ Id: "internal" }, {}, null);
  expect(getSession().sessionToken).toBeNull();
});

it("still expires while an access request is stalled", async () => {
  login(1000);
  getAccess.mockReturnValue(new Promise(() => {}));
  mount();
  await flush();
  jest.advanceTimersByTime(1000);
  await flush();
  expect(replace).toHaveBeenCalledWith("/PulseWorkChrono/login");
});
