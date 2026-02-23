import { LightningElement } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";

import smarthr_assets from "@salesforce/resourceUrl/smarthr_assets";
import chartjs from "@salesforce/resourceUrl/chartjs"; // update if your Chart.js static resource name differs

export default class HelpDeskDashboard extends LightningElement {
  assetsBase = smarthr_assets;

  _chartJsLoaded = false;
  _charts = [];

  get avatar01() {
    return `${this.assetsBase}/assets/img/avatar/avatar-01.png`;
  }
  get avatar02() {
    return `${this.assetsBase}/assets/img/avatar/avatar-02.png`;
  }
  get avatar03() {
    return `${this.assetsBase}/assets/img/avatar/avatar-03.jpg`;
  }
  get avatar04() {
    return `${this.assetsBase}/assets/img/avatar/avatar-04.png`;
  }

  renderedCallback() {
    if (this._chartJsLoaded) return;
    this._chartJsLoaded = true;

    loadScript(this, chartjs)
      .then(() => {
        this.initCharts();
      })
      .catch((e) => {
        // eslint-disable-next-line no-console
        console.error("Chart.js failed to load", e);
      });
  }

  disconnectedCallback() {
    this.destroyCharts();
  }

  destroyCharts() {
    try {
      this._charts.forEach((c) => c && c.destroy && c.destroy());
    } catch (e) {
      // ignore
    }
    this._charts = [];
  }

  initCharts() {
    if (!window.Chart) return;

    this.destroyCharts();

    const Chart = window.Chart;

    const ticketTrendsCanvas = this.template.querySelector(
      "canvas#ticket-trends-chart"
    );
    const ticketStatusCanvas = this.template.querySelector(
      "canvas#ticket-status-chart"
    );
    const slaCanvas = this.template.querySelector(
      "canvas#sla-compliance-chart"
    );
    const backlogCanvas = this.template.querySelector(
      "canvas#backlog-growth-chart"
    );
    const categoryCanvas = this.template.querySelector(
      "canvas#ticket-category"
    );

    // Global defaults (keep minimal so SmartHR styling stays dominant)
    Chart.defaults.responsive = true;
    Chart.defaults.maintainAspectRatio = false;
    Chart.defaults.plugins.legend.display = false;

    // Ticket Trends (line)
    if (ticketTrendsCanvas) {
      ticketTrendsCanvas.parentElement.style.height = "240px";

      const c = new Chart(ticketTrendsCanvas.getContext("2d"), {
        type: "line",
        data: {
          labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          datasets: [
            {
              label: "Created",
              data: [140, 155, 190, 150, 160, 175, 180],
              tension: 0.35,
              pointRadius: 2,
              borderWidth: 2
            },
            {
              label: "Resolved",
              data: [40, 65, 105, 70, 85, 75, 90],
              tension: 0.35,
              pointRadius: 2,
              borderWidth: 2
            }
          ]
        },
        options: {
          plugins: { legend: { display: false } },
          scales: {
            x: { grid: { display: false } },
            y: { beginAtZero: true }
          }
        }
      });

      this._charts.push(c);
    }

    // Tickets by Status (doughnut)
    if (ticketStatusCanvas) {
      ticketStatusCanvas.parentElement.style.height = "230px";

      const c = new Chart(ticketStatusCanvas.getContext("2d"), {
        type: "doughnut",
        data: {
          labels: ["Open", "In Progress", "On Hold", "Closed"],
          datasets: [
            {
              data: [653, 342, 185, 67],
              borderWidth: 0,
              cutout: "70%"
            }
          ]
        },
        options: {
          plugins: { legend: { display: false } }
        }
      });

      this._charts.push(c);
    }

    // SLA Compliance (semi-doughnut gauge)
    if (slaCanvas) {
      slaCanvas.parentElement.style.height = "200px";

      const slaValue = 80.5;
      const c = new Chart(slaCanvas.getContext("2d"), {
        type: "doughnut",
        data: {
          labels: ["SLA", "Remaining"],
          datasets: [
            {
              data: [slaValue, 100 - slaValue],
              borderWidth: 0,
              cutout: "78%"
            }
          ]
        },
        options: {
          rotation: -90,
          circumference: 180,
          plugins: { legend: { display: false } }
        }
      });

      this._charts.push(c);
    }

    // Backlog Growth (bar)
    if (backlogCanvas) {
      backlogCanvas.parentElement.style.height = "200px";

      const c = new Chart(backlogCanvas.getContext("2d"), {
        type: "bar",
        data: {
          labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
          datasets: [
            {
              label: "Backlog",
              data: [120, 300, 340, 410, 460, 520, 560],
              borderWidth: 0,
              borderRadius: 8
            }
          ]
        },
        options: {
          plugins: { legend: { display: false } },
          scales: {
            x: { grid: { display: false } },
            y: { beginAtZero: true }
          }
        }
      });

      this._charts.push(c);
    }

    // Tickets by Category (semi-doughnut)
    if (categoryCanvas) {
      categoryCanvas.parentElement.style.height = "200px";

      const c = new Chart(categoryCanvas.getContext("2d"), {
        type: "doughnut",
        data: {
          labels: [
            "IT Support",
            "HR",
            "Payroll",
            "Access",
            "Hardware",
            "Other"
          ],
          datasets: [
            {
              data: [485, 342, 268, 195, 412, 145],
              borderWidth: 0,
              cutout: "75%"
            }
          ]
        },
        options: {
          rotation: -90,
          circumference: 180,
          plugins: { legend: { display: false } }
        }
      });

      this._charts.push(c);
    }
  }
}
