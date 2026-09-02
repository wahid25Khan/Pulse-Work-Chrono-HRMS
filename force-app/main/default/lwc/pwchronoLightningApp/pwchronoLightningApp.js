import { LightningElement, track } from "lwc";
import { getCurrentPage, onPageChange } from "c/pwchronoRouter";

const ROUTES = new Set([
  "dashboard",
  "attendance",
  "leave",
  "holidays",
  "directory",
  "recruitment",
  "onboarding",
  "performance",
  "training",
  "expenses",
  "payroll",
  "profile",
  "configuration"
]);

const ROUTE_ALIASES = {
  "attendance management": "attendance",
  "attendance employee": "attendance",
  "leave management": "leave",
  leaves: "leave",
  "employee directory": "directory",
  "expense management": "expenses",
  expenses: "expenses",
  "my profile": "profile",
  administration: "configuration"
};

export default class PwchronoLightningApp extends LightningElement {
  @track currentRoute = "dashboard";
  unsubscribePageChange;

  connectedCallback() {
    this.setRoute(getCurrentPage());
    this.unsubscribePageChange = onPageChange((page) => this.setRoute(page));
  }

  disconnectedCallback() {
    this.unsubscribePageChange?.();
    this.unsubscribePageChange = undefined;
  }

  setRoute(page) {
    const requestedRoute = String(page || "")
      .trim()
      .toLowerCase();
    const normalized = ROUTE_ALIASES[requestedRoute] || requestedRoute;
    this.currentRoute = ROUTES.has(normalized) ? normalized : "dashboard";
  }

  handleNavigate(event) {
    this.setRoute(event.detail?.page);
  }

  get isDashboard() {
    return this.currentRoute === "dashboard";
  }
  get isAttendance() {
    return this.currentRoute === "attendance";
  }
  get isLeave() {
    return this.currentRoute === "leave";
  }
  get isHolidays() {
    return this.currentRoute === "holidays";
  }
  get isDirectory() {
    return this.currentRoute === "directory";
  }
  get isRecruitment() {
    return this.currentRoute === "recruitment";
  }
  get isOnboarding() {
    return this.currentRoute === "onboarding";
  }
  get isPerformance() {
    return this.currentRoute === "performance";
  }
  get isTraining() {
    return this.currentRoute === "training";
  }
  get isExpenses() {
    return this.currentRoute === "expenses";
  }
  get isPayroll() {
    return this.currentRoute === "payroll";
  }
  get isProfile() {
    return this.currentRoute === "profile";
  }
  get isConfiguration() {
    return this.currentRoute === "configuration";
  }
}
