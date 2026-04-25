import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    points: Array,
  }

  connect() {
    this.renderChart()
  }

  disconnect() {
    this.chart?.destroy()
    this.chart = null
  }

  renderChart() {
    if (!this.hasCanvasTarget || !this.pointsValue?.length) {
      return
    }

    const context = this.canvasTarget.getContext("2d")

    if (!context) {
      return
    }

    this.chart?.destroy()

    const labels = this.pointsValue.map((point) => point.label)
    const temperatures = this.pointsValue.map((point) => Number(point.value))

    this.chart = new Chart(context, {
      type: "line",
      data: {
        labels,
        datasets: [
          {
            label: "Temperatura",
            data: temperatures,
            borderColor: "#0f766e",
            backgroundColor: "rgba(15, 118, 110, 0.16)",
            borderWidth: 2,
            fill: true,
            tension: 0.35,
            pointBackgroundColor: "#0f766e",
            pointBorderColor: "#ffffff",
            pointBorderWidth: 2,
            pointRadius: 3,
            pointHoverRadius: 5,
          },
        ],
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
            display: false,
          },
          tooltip: {
            displayColors: false,
            callbacks: {
              label: (context) => `${context.parsed.y.toFixed(2)} °C`,
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
}
