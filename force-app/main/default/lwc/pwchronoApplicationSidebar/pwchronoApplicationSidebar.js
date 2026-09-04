import smarthrAssets from "@salesforce/resourceUrl/smarthr_assets";
import { api, LightningElement, track } from "lwc";

const NAV_ITEMS = [
  ["dashboard", "Dashboard", "fa-solid fa-house fa-fw"],
  ["profile", "My Profile", "fa-solid fa-address-card fa-fw"],
  ["attendance", "Attendance", "fa-solid fa-user-clock fa-fw"],
  ["leave", "Leave Management", "fa-solid fa-calendar-minus fa-fw"],
  ["holidays", "Holidays", "fa-solid fa-plane-departure fa-fw"],
  ["directory", "Employee Directory", "fa-solid fa-address-book fa-fw"],
  ["recruitment", "Recruitment", "fa-solid fa-user-plus fa-fw"],
  ["onboarding", "Onboarding", "fa-solid fa-person-circle-check fa-fw"],
  ["performance", "Performance", "fa-solid fa-chart-simple fa-fw"],
  ["goals", "Goals", "fa-solid fa-crosshairs fa-fw"],
  ["training", "Training", "fa-solid fa-chalkboard-user fa-fw"],
  ["projects", "Projects", "fa-solid fa-folder-tree fa-fw"],
  ["expenses", "Expenses", "fa-solid fa-wallet fa-fw"],
  ["payroll", "Payroll", "fa-solid fa-file-invoice-dollar fa-fw"],
  ["approvals", "Approvals", "fa-solid fa-circle-check fa-fw"],
  ["policies", "Company Policies", "fa-solid fa-file-shield fa-fw"],
  ["reports", "Reports", "fa-solid fa-chart-column fa-fw"],
  ["configuration", "Configuration", "fa-solid fa-sliders fa-fw"]
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
