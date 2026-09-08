import { createElement } from "lwc";
import Directory from "c/pwchronoEmployeeDirectory";
import getEmployees from "@salesforce/apex/PWChrono_EmployeeDirectoryController.getEmployees";
import getMetrics from "@salesforce/apex/PWChrono_EmployeeDirectoryController.getEmployeeDirectoryMetrics";
import getDesignations from "@salesforce/apex/PWChrono_EmployeeDirectoryController.getEmployeeDesignations";
jest.mock("c/pwchronoSession", () => ({
  getEmployeeId: () => "employee",
  getSessionToken: () => "session"
}));
jest.mock(
  "@salesforce/apex/PWChrono_EmployeeDirectoryController.getEmployees",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_EmployeeDirectoryController.getEmployeeDirectoryMetrics",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_EmployeeDirectoryController.getEmployeeDesignations",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
const flush = async () => {
  await Promise.resolve();
  await Promise.resolve();
};
describe("Employee directory finishing states", () => {
  beforeEach(() => {
    getEmployees.mockResolvedValue([]);
    getMetrics.mockResolvedValue({ total: 0 });
    getDesignations.mockResolvedValue([]);
  });
  afterEach(() => {
    document.body.replaceChildren();
    jest.clearAllMocks();
  });
  async function mount() {
    const e = createElement("c-pwchrono-employee-directory", { is: Directory });
    document.body.appendChild(e);
    await flush();
    return e;
  }
  it("distinguishes an unsuccessful request from a genuinely empty directory", async () => {
    getEmployees.mockRejectedValueOnce({ body: { message: "Unavailable" } });
    const e = await mount();
    expect(e.textContent).toContain("Unable to load employees");
    expect(e.textContent).not.toContain("No employees found");
    e.querySelector('[role="alert"] button').click();
    await flush();
    expect(e.querySelector('[role="alert"]')).toBeNull();
    expect(e.textContent).toContain("No employees found");
  });
  it("exposes the selected directory view", async () => {
    const e = await mount();
    const grid = e.querySelector('[aria-label="Grid View"]');
    grid.click();
    await flush();
    expect(grid.getAttribute("aria-pressed")).toBe("true");
    expect(e.textContent).toContain("Employees Grid");
  });
});
