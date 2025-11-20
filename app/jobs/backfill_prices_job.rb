class BackfillPricesJob < ApplicationJob
  queue_as :default

  # Backfill a narrow window, e.g., around a transaction's time
  def perform(coin_id, from_time, to_time)
    coin = Coin.find_by(id: coin_id)
    return unless coin

    service = BackfillPricesService.new
    service.run(coin: coin, from: Time.parse(from_time.to_s), to: Time.parse(to_time.to_s), resolution: :hourly)
  end
end
