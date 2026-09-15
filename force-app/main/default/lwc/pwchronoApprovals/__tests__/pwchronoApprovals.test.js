import { createElement } from "lwc";
import Component from "c/pwchronoApprovals";
import getLeaves from "@salesforce/apex/PWChrono_PortalApi.getTeamLeavesForApproval";
import getAttendance from "@salesforce/apex/PWChrono_PortalApi.getTeamAttendanceForApproval";
import processLeave from "@salesforce/apex/PWChrono_PortalApi.processLeaveApproval";
import processAttendance from "@salesforce/apex/PWChrono_PortalApi.processAttendanceApproval";
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.getTeamLeavesForApproval",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.getTeamAttendanceForApproval",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.processLeaveApproval",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.processAttendanceApproval",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock("c/pwchronoSession", () => ({
  getEmployeeId: () => "employee",
  getSessionToken: () => "session",
  SESSION_CHANGED_EVENT: "session-change"
}));
const flush = async () => {
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
};
const row = {
  Id: "request",
  Name: "Request 1",
  Employees__r: { Name: "Ayesha" },
  Status__c: "Submitted",
  From_Date__c: "2026-09-12",
  To_Date__c: "2026-09-12"
};
function mount() {
  const element = createElement("c-pwchrono-approvals", { is: Component });
  document.body.appendChild(element);
  return element;
}
beforeEach(() => {
  jest.clearAllMocks();
  getLeaves.mockResolvedValue([row]);
  getAttendance.mockResolvedValue([row]);
  processLeave.mockResolvedValue({});
  processAttendance.mockResolvedValue({});
});
afterEach(() => {
  while (document.body.firstChild) document.body.firstChild.remove();
});
it("requires confirmation and rejection comments before sending an authorized write", async () => {
  const element = mount();
  await flush();
  element.querySelector('[data-action="Reject"]').click();
  await flush();
  expect(processLeave).not.toHaveBeenCalled();
  element.querySelector('[role="dialog"] .btn-primary').click();
  await flush();
  expect(processLeave).not.toHaveBeenCalled();
  const input = element.querySelector("textarea");
  input.value = "Coverage needed";
  input.dispatchEvent(new CustomEvent("change"));
  element.querySelector('[role="dialog"] .btn-primary').click();
  await flush();
  expect(processLeave).toHaveBeenCalledWith({
    leaveId: "request",
    action: "Reject",
    comments: "Coverage needed",
    employeeId: "employee",
    sessionToken: "session"
  });
});
it("switches to the attendance workflow and refreshes after approval", async () => {
  const element = mount();
  await flush();
  const select = element.querySelector("select");
  select.value = "attendance";
  select.dispatchEvent(new CustomEvent("change"));
  await flush();
  element.querySelector('[data-action="Approve"]').click();
  await flush();
  element.querySelector('[role="dialog"] .btn-primary').click();
  await flush();
  expect(processAttendance).toHaveBeenCalledWith(
    expect.objectContaining({
      requestId: "request",
      action: "Approve",
      sessionToken: "session"
    })
  );
  expect(getAttendance).toHaveBeenCalledTimes(2);
});
it("shows loading errors instead of claiming the queue is empty", async () => {
  getLeaves.mockRejectedValue({ body: { message: "Access denied" } });
  const element = mount();
  await flush();
  expect(element.querySelector('[role="alert"]').textContent).toContain(
    "Access denied"
  );
  expect(element.textContent).not.toContain("caught up");
});
it("ignores an older response after the request type changes", async () => {
  let resolve;
  getLeaves.mockReturnValue(
    new Promise((r) => {
      resolve = r;
    })
  );
  const element = mount();
  await flush();
  const select = element.querySelector("select");
  select.value = "attendance";
  select.dispatchEvent(new CustomEvent("change"));
  await flush();
  resolve([{ ...row, Employees__r: { Name: "Stale" } }]);
  await flush();
  expect(element.textContent).not.toContain("Stale");
});
