import { createElement } from "lwc";
import Chat from "c/pwchronoChat";
import getSalesforceChatterUrl from "@salesforce/apex/PWChrono_AuthController.getSalesforceChatterUrl";
jest.mock(
  "@salesforce/apex/PWChrono_AuthController.getSalesforceChatterUrl",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock("@salesforce/user/isGuest", () => ({ default: true }), {
  virtual: true
});
afterEach(() => {
  while (document.body.firstChild) document.body.firstChild.remove();
});
it("uses the server supplied Salesforce Chatter destination instead of OTP login", async () => {
  getSalesforceChatterUrl.mockResolvedValue(
    "https://example.my.salesforce.com/lightning/page/chatter"
  );
  const element = createElement("c-pwchrono-chat", { is: Chat });
  document.body.appendChild(element);
  await Promise.resolve();
  await Promise.resolve();
  expect(element.shadowRoot.querySelector("a").href).toBe(
    "https://example.my.salesforce.com/lightning/page/chatter"
  );
  expect(element.shadowRoot.querySelector("a").target).toBe("_blank");
});
it("offers retry if the Salesforce URL cannot be loaded", async () => {
  getSalesforceChatterUrl.mockRejectedValue(new Error("offline"));
  const element = createElement("c-pwchrono-chat", { is: Chat });
  document.body.appendChild(element);
  await Promise.resolve();
  await Promise.resolve();
  expect(element.shadowRoot.querySelector('[role="alert"]')).not.toBeNull();
  expect(element.shadowRoot.querySelector("a")).toBeNull();
});
