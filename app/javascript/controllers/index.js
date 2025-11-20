// Register controllers explicitly to avoid dynamic import issues with eager loader
import { application } from "controllers/application"
import PriceChartController from "controllers/price_chart_controller"

application.register("price-chart", PriceChartController)
