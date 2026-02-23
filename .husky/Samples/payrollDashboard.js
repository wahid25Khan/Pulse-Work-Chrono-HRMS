import { LightningElement } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";

import smarthr_assets from "@salesforce/resourceUrl/smarthr_assets";
import chartjs from "@salesforce/resourceUrl/chartjs"; // Change if your Chart.js static resource name differs

export default class PayrollDashboard extends LightningElement {
  assetsBase = smarthr_assets;

  _isInitialized = false;
  _charts = [];

  get bg04() {
    return `${this.assetsBase}/assets/img/bg/bg-04.png`;
  }

  renderedCallback() {
    if (this._isInitialized) return;
    this._isInitialized = true;

    loadScript(this, chartjs)
      .then(() => {
        this.initCharts();
      })
      .catch((e) => {
        // eslint-disable-next-line no-console
        console.error("Failed to load Chart.js", e);
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

    // Light touch defaults so SmartHR visual remains primary
    window.Chart.defaults.responsive = true;
    window.Chart.defaults.maintainAspectRatio = false;
    window.Chart.defaults.plugins.legend.display = false;

    this._charts.push(this.createSalaryRangeChart());
    this._charts.push(
      this.createBatchSparkline(
        "batchProcessChart1",
        [10, 14, 13, 18, 16, 20, 19]
      )
    );
    this._charts.push(
      this.createBatchSparkline("batchProcessChart2", [4, 6, 7, 8, 7, 9, 8])
    );
    this._charts.push(
      this.createBatchSparkline("batchProcessChart3", [5, 7, 8, 9, 9, 10, 11])
    );

    this._charts.push(this.createTrendChart());

    this._charts.push(
      this.createMiniBars("insuranceMiniChart", [3, 5, 4, 6, 5, 7, 6])
    );
    this._charts.push(
      this.createMiniBars("contributionMiniChart", [2, 3, 3, 4, 4, 5, 4])
    );
    this._charts.push(
      this.createMiniBars("healthMiniChart", [2, 2, 3, 3, 4, 4, 5])
    );
  }

  getCanvas(id) {
    return this.template.querySelector(`canvas#${id}`);
  }

  createSalaryRangeChart() {
    const canvas = this.getCanvas("salaryRangeChart");
    if (!canvas) return null;

    // match template height
    if (canvas.parentElement) canvas.parentElement.style.height = "255px";

    return new window.Chart(canvas.getContext("2d"), {
      type: "bar",
      data: {
        labels: ["$10k-$25k", "$25k-$50k", "$50k-$75k", "$75k-$100k", "$100k+"],
        datasets: [
          {
            label: "Employees",
            data: [120, 240, 400, 180, 60],
            borderWidth: 0,
            borderRadius: 10,
            barThickness: 24
          }
        ]
      },
      options: {
        scales: {
          x: { grid: { display: false } },
          y: { beginAtZero: true }
        }
      }
    });
  }

  createBatchSparkline(canvasId, points) {
    const canvas = this.getCanvas(canvasId);
    if (!canvas) return null;

    if (canvas.parentElement) canvas.parentElement.style.height = "45px";

    return new window.Chart(canvas.getContext("2d"), {
      type: "line",
      data: {
        labels: points.map((_, i) => `${i + 1}`),
        datasets: [
          {
            data: points,
            borderWidth: 2,
            tension: 0.35,
            pointRadius: 0,
            fill: true
          }
        ]
      },
      options: {
        plugins: { tooltip: { enabled: false } },
        scales: {
          x: { display: false, grid: { display: false } },
          y: { display: false, grid: { display: false } }
        }
      }
    });
  }

  createTrendChart() {
    const canvas = this.getCanvas("taxDeductionTrendChart");
    if (!canvas) return null;

    if (canvas.parentElement) canvas.parentElement.style.height = "220px";

    return new window.Chart(canvas.getContext("2d"), {
      type: "line",
      data: {
        labels: ["Aug", "Sep", "Oct", "Nov", "Dec", "Jan"],
        datasets: [
          {
            label: "Tax",
            data: [120, 118, 122, 110, 108, 112],
            borderWidth: 2,
            tension: 0.35,
            pointRadius: 2,
            fill: false
          },
          {
            label: "Deduction",
            data: [90, 92, 93, 88, 85, 89],
            borderWidth: 2,
            tension: 0.35,
            pointRadius: 2,
            fill: false
          }
        ]
      },
      options: {
        scales: {
          x: { grid: { display: false } },
          y: { beginAtZero: false }
        }
      }
    });
  }

  createMiniBars(canvasId, points) {
    const canvas = this.getCanvas(canvasId);
    if (!canvas) return null;

    if (canvas.parentElement) canvas.parentElement.style.height = "40px";

    return new window.Chart(canvas.getContext("2d"), {
      type: "bar",
      data: {
        labels: points.map((_, i) => `${i + 1}`),
        datasets: [
          {
            data: points,
            borderWidth: 0,
            borderRadius: 8,
            barThickness: 6
          }
        ]
      },
      options: {
        plugins: { tooltip: { enabled: false } },
        scales: {
          x: { display: false, grid: { display: false } },
          y: { display: false, grid: { display: false } }
        }
      }
    });
  }
}
