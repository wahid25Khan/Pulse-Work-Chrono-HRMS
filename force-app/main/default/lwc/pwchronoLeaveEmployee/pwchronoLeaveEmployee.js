import getMyLeaves from "@salesforce/apex/PWChrono_LeaveController.getMyLeaves";
import {
  initBootstrapCompat,
  teardownBootstrapCompat
} from "c/pwchronoBootstrapCompat";
import { getSession, getSessionToken } from "c/pwchronoSession";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { LightningElement, track } from "lwc";

export default class PwchronoLeaveEmployee extends LightningElement {
  @track myLeaves = [];
  @track allMyLeaves = [];
  @track isLoading = false;

  // Metrics
  @track annualLeaveCount = 12; // Example static or fetched
  @track medicalLeaveCount = 3;
  @track otherLeaveCount = 4;
  @track remainingLeaveCount = 5;

  @track statusFilter = "All";
  @track startDate = null;
  @track endDate = null;

  employeeId;
  sessionToken;

  // Dropdown State
  @track showExportDropdown = false;
  @track showFilterDropdown = false;
  hasRendered = false;
  _boundCloseDropdowns;

  connectedCallback() {
    const session = getSession();
    this.employeeId = session.user ? session.user.Id : null;
    this.sessionToken = getSessionToken();
    this.loadLeaveRequests();
  }

  renderedCallback() {
    initBootstrapCompat(this);
    if (!this.hasRendered) {
      this.hasRendered = true;
      this._boundCloseDropdowns = this.closeDropdowns.bind(this);
      globalThis.addEventListener("click", this._boundCloseDropdowns);
    }
  }

  disconnectedCallback() {
    teardownBootstrapCompat(this);
    if (this._boundCloseDropdowns) {
      globalThis.removeEventListener("click", this._boundCloseDropdowns);
    }
  }

  closeDropdowns() {
    this.showExportDropdown = false;
    this.showFilterDropdown = false;
  }

  toggleExportDropdown(event) {
    event.preventDefault();
    event.stopPropagation();
    this.showExportDropdown = !this.showExportDropdown;
    this.showFilterDropdown = false;
  }

  toggleFilterDropdown(event) {
    event.preventDefault();
    event.stopPropagation();
    this.showFilterDropdown = !this.showFilterDropdown;
    this.showExportDropdown = false;
  }

  get exportDropdownClass() {
    return this.showExportDropdown
      ? "dropdown-menu dropdown-menu-end p-3 show"
      : "dropdown-menu dropdown-menu-end p-3";
  }

  get filterDropdownClass() {
    return this.showFilterDropdown
      ? "dropdown-menu dropdown-menu-end p-3 show"
      : "dropdown-menu dropdown-menu-end p-3";
  }

  async loadLeaveRequests() {
    this.isLoading = true;
    try {
      const result = await getMyLeaves({
        statusFilter: this.statusFilter,
        startDate: this.startDate,
        endDate: this.endDate,
        employeeId: this.employeeId,
        sessionToken: this.sessionToken
      });
      if (result) {
        this.allMyLeaves = result.map((record) => ({
          ...record,
          leaveTypeName: record.Leave_Type__r
            ? record.Leave_Type__r.Name
            : "Other",
          statusClass: this.getStatusClass(record.Status__c),
          formattedStartDate: record.Start_Date__c,
          formattedEndDate: record.End_Date__c,
          totalDays: record.Total_Days__c || 1
        }));
        this.myLeaves = [...this.allMyLeaves];
        // Calculate metrics if needed based on data
      }
    } catch (error) {
      this.showToast(
        "Error",
        "Failed to load leaves: " +
          (error.body ? error.body.message : error.message),
        "error"
      );
    } finally {
      this.isLoading = false;
    }
  }

  getStatusClass(status) {
    // Map status to badge classes if needed
    return status;
  }

  handleStatusFilter(event) {
    event.preventDefault();
    event.stopPropagation();
    this.statusFilter = event.target.dataset.value;
    this.loadLeaveRequests();
  }

  handleDateFilter(event) {
    const val = event.target.value;
    if (val) {
      this.startDate = val;
    } else {
      this.startDate = null;
    }
    this.loadLeaveRequests();
  }

  handleNoop(event) {
    event?.preventDefault();
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}