class BackfillCoinYearJob < ApplicationJob
  queue_as :default

  def perform(coin_id)
    coin = Coin.find_by(id: coin_id)
    return unless coin

    service = BackfillPricesService.new

    # Daily series for ~1 year
    service.run(coin: coin, from: 1.year.ago.beginning_of_day, to: Time.current, resolution: :daily)

    # Hourly series for ~90 days
    service.run(coin: coin, from: 90.days.ago, to: Time.current, resolution: :hourly)
  end
end
