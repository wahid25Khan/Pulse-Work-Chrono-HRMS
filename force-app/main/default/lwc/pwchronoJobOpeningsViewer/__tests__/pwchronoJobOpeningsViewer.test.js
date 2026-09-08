import { createElement } from "lwc";
import Jobs from "c/pwchronoJobOpeningsViewer";
import getJobs from "@salesforce/apex/PWChrono_RecruitmentController.getJobOpenings";
import referCandidate from "@salesforce/apex/PWChrono_RecruitmentController.referCandidate";
jest.mock(
  "@salesforce/apex/PWChrono_RecruitmentController.getJobOpenings",
  () => ({
    default: require("@salesforce/sfdx-lwc-jest").createApexTestWireAdapter(
      jest.fn()
    )
  }),
  { virtual: true }
);
jest.mock(
  "@salesforce/apex/PWChrono_RecruitmentController.referCandidate",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock("c/pwchronoSession", () => ({
  getEmployeeId: jest.fn(() => "employee"),
  getSessionToken: jest.fn(() => "session")
}));
const flush = async () => {
  await Promise.resolve();
  await Promise.resolve();
};
describe("Job openings UI", () => {
  afterEach(() => {
    document.body.replaceChildren();
    jest.clearAllMocks();
  });
  async function mount() {
    const e = createElement("c-pwchrono-job-openings-viewer", { is: Jobs });
    document.body.appendChild(e);
    getJobs.emit([
      {
        Id: "job-1",
        Name: "Developer",
        Department__r: { Name: "Engineering" },
        No_of_Positions__c: 1
      }
    ]);
    await flush();
    return e;
  }
  it("searches positions and resets", async () => {
    const e = await mount();
    const input = e.querySelector('input[type="search"]');
    input.value = "unmatched";
    input.dispatchEvent(new CustomEvent("input"));
    await flush();
    expect(e.textContent).toContain("No open positions match");
    e.querySelector("button").click();
    await flush();
    expect(e.textContent).toContain("Developer");
  });
  it("opens a referral when the icon inside its button is clicked", async () => {
    const e = await mount();
    e.querySelector('button[data-id="job-1"] i').click();
    await flush();
    expect(e.querySelector(".modal-title").textContent).toContain("Developer");
    expect(e.querySelector('input[name="email"]').required).toBe(true);
  });
  it("does not submit an empty referral", async () => {
    const e = await mount();
    e.querySelector('button[data-id="job-1"]').click();
    await flush();
    Array.from(e.querySelectorAll("button"))
      .find((b) => b.textContent.includes("Submit Referral"))
      .click();
    expect(referCandidate).not.toHaveBeenCalled();
  });
  it("supports Escape and restores focus to the referral action", async () => {
    const e = await mount();
    const opener = e.querySelector('button[data-id="job-1"]');
    opener.click();
    await flush();
    expect(document.activeElement).toBe(
      e.querySelector('input[name="firstName"]')
    );
    e.querySelector(".modal").dispatchEvent(
      new KeyboardEvent("keydown", { key: "Escape", bubbles: true })
    );
    await flush();
    expect(e.querySelector(".modal")).toBeNull();
    expect(document.activeElement).toBe(opener);
  });
});
