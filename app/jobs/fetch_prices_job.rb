class FetchPricesJob < ApplicationJob
  queue_as :default

  def perform
    Coin.all.each do |coin|
      price = CoingeckoService.fetch_current_price(coin.coingecko_id)
      if price.present?
        Price.create(
          coin_id: coin.id,
          price: price,
          recorded_at: Time.current
        )
        log_info("✅ Fetched price for #{coin.coin_name}: $#{price}")
      else
        log_error("❌ Fetch failed for #{coin.coin_name}")
      end
    end
  end
end
