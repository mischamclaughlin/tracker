class FetchPricesJob < ApplicationJob
  queue_as :default

  def perform
    Asset.all.each do |asset|
      next unless asset.price_trackable?

      price = CoingeckoService.fetch_current_price(asset.coingecko_id)
      if price.present?
        Price.create(
          asset: asset.name,
          price: price,
          recorded_at: Time.current
        )
        log_info("✅ Fetched price for #{asset.name}: $#{price}")
      else
        log_error("❌ Fetch failed for #{asset.name}")
      end
    end
  end
end
