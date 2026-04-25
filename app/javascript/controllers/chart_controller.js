import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    points: Array,
    series: Object,
  }

  connect() {
    this.renderChart()
  }

  disconnect() {
    this.chart?.destroy()
    this.chart = null
  }

  renderChart() {
    if (!this.hasCanvasTarget) {
      return
    }

    const series = this.resolveSeries()

    if (!series || !series.labels.length || !series.datasets.length) {
      return
    }

    const context = this.canvasTarget.getContext("2d")

    if (!context) {
      return
    }

    this.chart?.destroy()
    const datasets = this.buildDatasets(series.datasets)

    this.chart = new Chart(context, {
      type: "line",
      data: {
        labels: series.labels,
        datasets,
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          mode: "index",
          intersect: false,
        },
        plugins: {
          legend: {
            display: datasets.length > 1,
          },
          tooltip: {
            displayColors: true,
            callbacks: {
              label: (context) => `${context.dataset.label}: ${context.parsed.y.toFixed(2)} °C`,
            },
          },
        },
        scales: {
          x: {
            grid: {
              color: "rgba(148, 163, 184, 0.12)",
            },
            ticks: {
              color: "#475569",
              maxRotation: 0,
              autoSkip: true,
            },
          },
          y: {
            beginAtZero: false,
            grid: {
              color: "rgba(148, 163, 184, 0.12)",
            },
            ticks: {
              color: "#475569",
              callback: (value) => `${value} °C`,
            },
          },
        },
      },
    })
  }

  resolveSeries() {
    if (this.hasSeriesValue && this.seriesValue?.labels?.length && this.seriesValue?.datasets?.length) {
      return this.seriesValue
    }

    if (this.pointsValue?.length) {
      return {
        labels: this.pointsValue.map((point) => point.label),
        datasets: [
          {
            key: "legacy",
            label: "Temperatura",
            values: this.pointsValue.map((point) => Number(point.value)),
          },
        ],
      }
    }

    return null
  }

  buildDatasets(rawDatasets) {
    const palette = {
      arduino: {
        borderColor: "#0f766e",
        backgroundColor: "rgba(15, 118, 110, 0.16)",
      },
      open_meteo: {
        borderColor: "#ea580c",
        backgroundColor: "rgba(234, 88, 12, 0.16)",
      },
      legacy: {
        borderColor: "#0f766e",
        backgroundColor: "rgba(15, 118, 110, 0.16)",
      },
    }

    return rawDatasets.map((dataset, index) => {
      const colors = palette[dataset.key] || {
        borderColor: "#334155",
        backgroundColor: "rgba(51, 65, 85, 0.12)",
      }

      return {
        label: dataset.label,
        data: dataset.values.map((value) => (value == null ? null : Number(value))),
        borderColor: colors.borderColor,
        backgroundColor: colors.backgroundColor,
        borderWidth: 2,
        fill: true,
        tension: 0.35,
        spanGaps: true,
        pointBackgroundColor: colors.borderColor,
        pointBorderColor: "#ffffff",
        pointBorderWidth: 2,
        pointRadius: 3,
        pointHoverRadius: 5,
        order: index,
      }
    })
  }
}
