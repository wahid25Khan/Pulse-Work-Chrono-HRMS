import { LightningElement, api, track } from "lwc";

export default class PwchronoPerformanceManagement extends LightningElement {
  // Label placeholders (No hardcoding)
  // Public so parent components can override, but we provide safe defaults.
  // IMPORTANT: Do not reassign @api properties within the component.
  @api pageTitle = "Performance Indicator";
  @api breadcrumbParent = "Performance";
  @api breadcrumbActive = "Performance Indicator";
  @api addBtnLabel = "Add New Indicator";
  @api listTitle = "Performance Indicator List";
  @api sortByLabel = "Sort By : Last 7 Days";

  // Table Header Labels
  @api colDesignation = "Designation";
  @api colDepartment = "Department";
  @api colApprovedBy = "Approved By";
  @api colCreatedDate = "Created Date";
  @api colStatus = "Status";

  @track indicatorData = [];
  @track isModalOpen = false;
  @track isEditing = false;
  @track selectedIndicator = {};

  connectedCallback() {
    this.loadComponentData();
  }

  /**
   * LOAD FUNCTION: Initializes all labels and mock data
   */
  @api
  loadComponentData() {
    // Mock Data
    const mockData = [
      {
        id: "1",
        designation: "Web Designer",
        department: "Designing",
        approvedByName: "Doglas Martini",
        approvedByRole: "Manager",
        approvedByImg: "assets/img/users/user-34.jpg",
        createdDate: "14 Jan 2024",
        status: "Active"
      }
    ];

    this.refreshTable(mockData);
  }

  refreshTable(data) {
    this.indicatorData = data.map((item) => ({
      ...item,
      statusClass:
        item.status === "Active"
          ? "badge badge-success d-inline-flex align-items-center badge-xs"
          : "badge badge-danger d-inline-flex align-items-center badge-xs"
    }));
  }

  handleActionClick(event) {
    const action = event.currentTarget.dataset.action;
    const recordId = event.currentTarget.dataset.id;

    switch (action) {
      case "openAdd":
        this.isEditing = false;
        this.selectedIndicator = { status: "Active" };
        this.isModalOpen = true;
        break;
      case "edit": {
        this.isEditing = true;
        const record = this.indicatorData.find((item) => item.id === recordId);
        this.selectedIndicator = { ...record };
        this.isModalOpen = true;
        break;
      }
      case "delete":
        this.refreshTable(
          this.indicatorData.filter((item) => item.id !== recordId)
        );
        break;
      case "closeModal":
        this.isModalOpen = false;
        break;
      case "save":
        this.handleSave();
        break;
      default:
        // no-op
        break;
    }
  }

  handleInputChange(event) {
    this.selectedIndicator[event.target.name] = event.target.value;
  }

  handleSave() {
    let currentData = [...this.indicatorData];
    if (this.isEditing) {
      currentData = currentData.map((item) => {
        return item.id === this.selectedIndicator.id
          ? { ...this.selectedIndicator }
          : item;
      });
    } else {
      currentData.push({
        ...this.selectedIndicator,
        id: Date.now().toString(),
        createdDate: "Today"
      });
    }
    this.refreshTable(currentData);
    this.isModalOpen = false;
  }
}