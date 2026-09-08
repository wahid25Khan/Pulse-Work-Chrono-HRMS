import { createElement } from "lwc";
import Leaves from "c/pwchronoLeaveEmployee";
import getLeaves from "@salesforce/apex/PWChrono_LeaveController.getMyLeaves";
import getBalance from "@salesforce/apex/PWChrono_LeaveController.getMyLeaveBalance";
import saveLeave from "@salesforce/apex/PWChrono_LeaveController.saveLeaveApplication";
jest.mock("c/pwchronoSession", () => ({
  getSession: jest.fn(() => ({ user: { Id: "employee" } })),
  getSessionToken: jest.fn(() => "session")
}));
jest.mock(
  "@salesforce/apex/PWChrono_LeaveController.getMyLeaves",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_LeaveController.getMyLeaveBalance",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_LeaveController.saveLeaveApplication",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
const flush = async () => {
  await Promise.resolve();
  await Promise.resolve();
};
describe("Employee leave page", () => {
  beforeEach(() => {
    getLeaves.mockResolvedValue([
      {
        Id: "leave-1",
        Leave_Type__r: { Name: "Annual" },
        From_Date__c: "2026-09-10",
        To_Date__c: "2026-09-11",
        Total_Days__c: 2,
        Status__c: "Submitted",
        Reason__c: "Family trip"
      }
    ]);
    getBalance.mockResolvedValue([]);
  });
  afterEach(() => {
    document.body.replaceChildren();
    jest.clearAllMocks();
  });
  async function mount() {
    const e = createElement("c-pwchrono-leave-employee", { is: Leaves });
    document.body.appendChild(e);
    await flush();
    return e.shadowRoot;
  }
  it("renders status as a badge, not an inert dropdown", async () => {
    const r = await mount();
    expect(r.querySelector("tbody .badge").textContent).toBe("Submitted");
    expect(r.querySelector("tbody .dropdown-toggle")).toBeNull();
  });
  it("searches leave requests and explains empty results", async () => {
    const r = await mount();
    const input = r.querySelector('input[type="search"]');
    input.value = "no match";
    input.dispatchEvent(new CustomEvent("input"));
    await flush();
    expect(r.querySelector("tbody").textContent).toContain(
      "No leave requests found"
    );
  });
  it("enforces required fields without submitting an empty request", async () => {
    const r = await mount();
    Array.from(r.querySelectorAll("button"))
      .find((b) => b.textContent.includes("New Leave"))
      .click();
    await flush();
    expect(r.querySelector('input[name="fromDate"]').required).toBe(true);
    r.querySelector("form").dispatchEvent(
      new CustomEvent("submit", { cancelable: true })
    );
    expect(saveLeave).not.toHaveBeenCalled();
  });
  it("shows failure separately from empty results and recovers on retry", async () => {
    getLeaves.mockRejectedValueOnce({ body: { message: "Expired session" } });
    const r = await mount();
    expect(r.querySelector('[role="alert"]').textContent).toContain(
      "Unable to load"
    );
    expect(r.querySelector("table")).toBeNull();
    r.querySelector('[role="alert"] button').click();
    await flush();
    expect(r.querySelector('[role="alert"]')).toBeNull();
    expect(r.querySelector("tbody").textContent).toContain("Family trip");
  });
  it("does not display a failed balance as a zero entitlement", async () => {
    getBalance.mockRejectedValueOnce(new Error("Unavailable"));
    const r = await mount();
    expect(r.textContent).toContain("Leave balances are unavailable");
    expect([...r.querySelectorAll("h3")].map((e) => e.textContent)).toEqual([
      "—",
      "—",
      "—",
      "—"
    ]);
  });
  it("ignores an older response after a later filter request", async () => {
    let resolveOld;
    getLeaves.mockReturnValueOnce(
      new Promise((resolve) => {
        resolveOld = resolve;
      })
    );
    const r = await mount();
    const status = r.querySelector('[name="statusFilter"]');
    status.value = "Submitted";
    status.dispatchEvent(new CustomEvent("change"));
    await flush();
    resolveOld([]);
    await flush();
    expect(r.querySelector("tbody").textContent).toContain("Family trip");
  });
});
