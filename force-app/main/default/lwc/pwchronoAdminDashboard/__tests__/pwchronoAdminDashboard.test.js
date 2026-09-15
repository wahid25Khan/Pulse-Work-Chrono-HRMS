import { createElement } from "lwc";
import Component from "c/pwchronoAdminDashboard";
import getStats from "@salesforce/apex/PWChrono_PortalApi.getAdminDashboardStats";
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.getAdminDashboardStats",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
import getDepartments from "@salesforce/apex/PWChrono_PortalApi.getEmployeesByDepartment";
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.getEmployeesByDepartment",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
import getAttendance from "@salesforce/apex/PWChrono_PortalApi.getAttendanceOverview";
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.getAttendanceOverview",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
import getProjects from "@salesforce/apex/PWChrono_PortalApi.getProjects";
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.getProjects",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
import getApplicants from "@salesforce/apex/PWChrono_PortalApi.getJobApplicants";
jest.mock(
  "@salesforce/apex/PWChrono_PortalApi.getJobApplicants",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock("c/pwchronoSession", () => ({
  getEmployeeId: () => "employee",
  getSessionToken: () => "session",
  getSession: () => ({ user: { Name: "Ayesha" } }),
  SESSION_CHANGED_EVENT: "session-change"
}));
const flush = async () => {
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
};
function mount() {
  const element = createElement("c-pwchrono-admin-dashboard", {
    is: Component
  });
  document.body.appendChild(element);
  return element;
}
beforeEach(() => {
  jest.clearAllMocks();
  getStats.mockResolvedValue({ totalEmployees: 42, pendingApprovals: 7 });
  getDepartments.mockResolvedValue([{ label: "Engineering", value: 12 }]);
  getAttendance.mockResolvedValue({
    day: "2026-09-10",
    present: 8,
    late: 2,
    permission: 1,
    absent: 0
  });
  getProjects.mockResolvedValue([]);
  getApplicants.mockResolvedValue([]);
});
afterEach(() => {
  while (document.body.firstChild) document.body.firstChild.remove();
});
it("renders actual records, labels statuses accurately, and exposes the recorded date", async () => {
  const element = mount();
  await flush();
  expect(element.textContent).toContain("42");
  expect(element.textContent).toContain("Engineering");
  expect(element.textContent).toContain("Submitted");
  expect(element.textContent).not.toContain("Daniel Esbella");
  expect(element.textContent).not.toContain("+2.1%");
  expect(element.querySelector("lightning-formatted-date-time").value).toBe(
    "2026-09-10"
  );
});
it("keeps successful sections while displaying a failed summary rather than zero cards", async () => {
  getStats.mockRejectedValue({ body: { message: "Access denied" } });
  const element = mount();
  await flush();
  expect(element.querySelector('[role="alert"]').textContent).toContain(
    "Access denied"
  );
  expect(element.querySelectorAll(".metric-grid .card")).toHaveLength(0);
  expect(element.textContent).toContain("Engineering");
});
