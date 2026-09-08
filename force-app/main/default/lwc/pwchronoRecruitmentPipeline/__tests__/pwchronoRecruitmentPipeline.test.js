import { createElement } from "lwc";
import Pipeline from "c/pwchronoRecruitmentPipeline";
import getApplicants from "@salesforce/apex/PWChrono_RecruitmentController.getJobApplicants";
import getAccess from "@salesforce/apex/PWChrono_AccessController.getUserAccessById";
jest.mock("c/pwchronoSession", () => ({
  getEmployeeId: jest.fn(() => "test-employee"),
  getSessionToken: jest.fn(() => "test-session")
}));
jest.mock(
  "@salesforce/apex/PWChrono_RecruitmentController.getJobApplicants",
  () => ({
    default: require("@salesforce/sfdx-lwc-jest").createApexTestWireAdapter(
      jest.fn()
    )
  }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_AccessController.getUserAccessById",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
const flush = async () => {
  await Promise.resolve();
  await Promise.resolve();
};
describe("SmartHR candidates grid", () => {
  beforeEach(() => getAccess.mockResolvedValue({ role: "HR Admin" }));
  afterEach(() => {
    document.body.replaceChildren();
    jest.clearAllMocks();
  });
  async function mount(data) {
    const element = createElement("c-pwchrono-recruitment-pipeline", {
      is: Pipeline
    });
    document.body.appendChild(element);
    await flush();
    getApplicants.emit(data);
    await flush();
    return element;
  }
  const data = [
    {
      Id: "one",
      Name: "Ada",
      Email__c: "ada@example.test",
      Status__c: "Applied",
      CreatedDate: "2026-09-01",
      Job_Opening__r: { Name: "Developer" }
    },
    {
      Id: "two",
      Name: "Zoe",
      Status__c: "Accepted",
      CreatedDate: "2026-09-02",
      Job_Opening__r: { Name: "Designer" }
    }
  ];
  it("renders real candidate cards and missing email fallback", async () => {
    const e = await mount(data);
    expect(e.querySelectorAll(".candidate-card")).toHaveLength(2);
    expect(e.textContent).toContain("Email not provided");
  });
  it("filters by search and resets the rendered native controls", async () => {
    const e = await mount(data);
    const search = e.querySelector('input[name="searchTerm"]');
    search.value = "developer";
    search.dispatchEvent(new CustomEvent("input"));
    await flush();
    expect(e.querySelectorAll(".candidate-card")).toHaveLength(1);
    const select = e.querySelector('select[name="statusFilter"]');
    select.value = "Accepted";
    select.dispatchEvent(new CustomEvent("change"));
    await flush();
    expect(e.textContent).toContain("No candidates found");
    Array.from(e.querySelectorAll("button"))
      .find((b) => b.textContent === "Reset")
      .click();
    await flush();
    expect(select.value).toBe("All");
    expect(e.querySelectorAll(".candidate-card")).toHaveLength(2);
  });
  it("switches to the existing board without duplicating grid cards", async () => {
    const e = await mount(data);
    e.querySelector('[data-view="board"]').click();
    await flush();
    expect(e.querySelector(".kanban-wrapper")).not.toBeNull();
    expect(e.querySelector(".candidate-card")).toBeNull();
  });
  it("renders a useful empty state", async () => {
    const e = await mount([]);
    expect(e.textContent).toContain("No candidates found");
  });
});
