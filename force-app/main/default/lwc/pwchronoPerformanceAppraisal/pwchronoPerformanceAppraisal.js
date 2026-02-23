import { LightningElement, api, track } from "lwc";

export default class PerformanceAppraisal extends LightningElement {
  // Labels (Dynamic for Reusability)
  @api pageTitle = "Performance Appraisal";
  @api breadcrumbParent = "Performance";
  @api breadcrumbActive = "Performance Appraisal";
  @api addBtnLabel = "Add Appraisal";
  @api listTitle = "Performance Appraisal List";
  @api sortByLabel = "Sort By : Last 7 Days";

  // Table Column Labels
  @api colName = "Name";
  @api colDesignation = "Designation";
  @api colDepartment = "Department";
  @api colAppraisalDate = "Appraisal Date";
  @api colStatus = "Status";

  @track appraisalData = [];
  @track isModalOpen = false;

  connectedCallback() {
    this.loadComponentData();
  }

  /**
   * LOAD FUNCTION: Initializes data for the view
   */
  @api
  loadComponentData() {
    const mockData = [
      {
        id: "1",
        name: "Anthony Lewis",
        img: "assets/img/users/user-32.jpg",
        designation: "Web Designer",
        department: "Designing",
        appraisalDate: "14 Jan 2024",
        status: "Active"
      },
      {
        id: "2",
        name: "Brian Villalobos",
        img: "assets/img/users/user-09.jpg",
        designation: "Web Developer",
        department: "Developer",
        appraisalDate: "21 Jan 2024",
        status: "Active"
      },
      {
        id: "3",
        name: "Harvey Smith",
        img: "assets/img/users/user-01.jpg",
        designation: "IOS Developer",
        department: "Developer",
        appraisalDate: "18 Feb 2024",
        status: "Active"
      }
    ];

    this.refreshTable(mockData);
  }

  refreshTable(data) {
    this.appraisalData = data.map((item) => ({
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
        this.isModalOpen = true;
        break;
      case "closeModal":
        this.isModalOpen = false;
        break;
      case "edit":
        console.log("Editing record:", recordId);
        this.isModalOpen = true;
        break;
      case "delete":
        this.refreshTable(
          this.appraisalData.filter((item) => item.id !== recordId)
        );
        break;
      default:
        break;
    }
  }
}
