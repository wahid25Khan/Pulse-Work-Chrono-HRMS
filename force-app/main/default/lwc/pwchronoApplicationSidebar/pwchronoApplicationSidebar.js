import smarthrAssets from "@salesforce/resourceUrl/smarthr_assets";
import { api, LightningElement, track } from "lwc";

const NAV_ITEMS = [
  ["dashboard", "Dashboard", "fa-solid fa-gauge fa-fw"],
  ["profile", "My Profile", "fa-solid fa-user fa-fw"],
  ["attendance", "Attendance", "fa-solid fa-calendar-check fa-fw"],
  ["leave", "Leave Management", "fa-solid fa-calendar-days fa-fw"],
  ["holidays", "Holidays", "fa-solid fa-umbrella-beach fa-fw"],
  ["directory", "Employee Directory", "fa-solid fa-users fa-fw"],
  ["recruitment", "Recruitment", "fa-solid fa-user-tie fa-fw"],
  ["onboarding", "Onboarding", "fa-solid fa-id-card-clip fa-fw"],
  ["performance", "Performance", "fa-solid fa-chart-line fa-fw"],
  ["goals", "Goals", "fa-solid fa-bullseye fa-fw"],
  ["training", "Training", "fa-solid fa-graduation-cap fa-fw"],
  ["projects", "Projects", "fa-solid fa-diagram-project fa-fw"],
  ["expenses", "Expenses", "fa-solid fa-receipt fa-fw"],
  ["payroll", "Payroll", "fa-solid fa-money-check-dollar fa-fw"],
  ["approvals", "Approvals", "fa-solid fa-list-check fa-fw"],
  ["policies", "Company Policies", "fa-solid fa-file-lines fa-fw"],
  ["reports", "Reports", "fa-solid fa-chart-pie fa-fw"],
  ["configuration", "Configuration", "fa-solid fa-gear fa-fw"]
];

export default class PwchronoApplicationSidebar extends LightningElement {
  static renderMode = "light";

  @api currentRoute = "dashboard";
  @track logoErrored = false;

  get logoUrl() {
    return `${smarthrAssets}/assets/img/logo.svg`;
  }

  get items() {
    return NAV_ITEMS.map(([route, label, iconClass]) => ({
      route,
      label,
      iconClass,
      href: `#${route}`,
      linkClass: route === this.currentRoute ? "active" : ""
    }));
  }

  handleLogoError() {
    this.logoErrored = true;
  }

  handleNavigate(event) {
    const route = event.currentTarget.dataset.route;
    if (!route) {
      return;
    }
    this.dispatchEvent(
      new CustomEvent("routechange", {
        detail: { route },
        bubbles: true,
        composed: true
      })
    );
  }
}
