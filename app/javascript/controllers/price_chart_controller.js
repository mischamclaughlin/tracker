import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"
import "chartjs-adapter-date-fns"

export default class extends Controller {
  static values = { coinId: Number, range: String, url: String }
  static targets = ["canvas"]

  connect() {
    this.loadAndRender()
  }

  async loadAndRender() {
    const range = this.rangeValue || "90d"
    const url = this.urlValue || `/coins/${this.coinIdValue}/chart_data?range=${range}`
    try {
      const res = await fetch(url, { headers: { Accept: "application/json" } })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const data = await res.json()

      const ctx = this.canvasTarget.getContext("2d")
      if (this.chart) this.chart.destroy()
      this.chart = new Chart(ctx, {
        type: "line",
        data: { datasets: [{ label: "Price (USD)", data, borderColor: "#3b82f6", pointRadius: 0, tension: 0.2 }] },
        options: {
          parsing: { xAxisKey: 'x', yAxisKey: 'y' },
          responsive: true,
          animation: false,
          scales: {
            x: { type: "time", time: { unit: this.timeUnit(range) }, ticks: { color: "#e5e7eb" }, grid: { color: "#374151" } },
            y: { beginAtZero: false, ticks: { color: "#e5e7eb" }, grid: { color: "#374151" } }
          },
          interaction: { mode: "index", intersect: false },
          plugins: { legend: { display: true, labels: { color: "#e5e7eb" } } }
        }
      })
    } catch (e) {
      console.error("Failed to load chart data", e)
    }
  }

  timeUnit(range) {
    switch (range) {
      case "24h": return "hour"
      case "7d":
      case "30d":
      case "90d":
      default: return "day"
    }
  }

  setRange(event) {
    const newRange = (event.params && event.params.range) || event.currentTarget?.dataset?.priceChartRangeParam
    if (newRange) this.rangeValue = newRange
    this.loadAndRender()
  }
}
