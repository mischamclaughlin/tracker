class CoingeckoService
  include HTTParty

  base_uri "https://api.coingecko.com/api/v3"

  def self.fetch_current_price(coingecko_id)
    response = get("/simple/price", query: {
      ids: coingecko_id,
      vs_currencies: "usd"
    })
    response.dig(coingecko_id, "usd")
  rescue => e
    Rails.logger.error("Error fetching current price for #{coingecko_id}: #{e.message}")
    nil
  end

  def self.fetch_historical_price(coingecko_id, time)
    if time > 90.days.ago
      fetch_from_market_chart_range(coingecko_id, time)
    else
      fetch_from_history(coingecko_id, time)
    end
  end

  # Bulk daily prices for up to the last year
  def self.fetch_market_chart_days(coingecko_id, days:, interval: "daily")
    response = get("/coins/#{coingecko_id}/market_chart", query: {
      vs_currency: "usd",
      days: days,
      interval: interval
    })
    response["prices"]
  rescue => e
    Rails.logger.error("Error fetching market_chart (days=#{days}, interval=#{interval}) for #{coingecko_id}: #{e.message}")
    nil
  end

  # Bulk range prices (typically ~hourly granularity)
  def self.fetch_market_chart_range(coingecko_id, from:, to:)
    response = get("/coins/#{coingecko_id}/market_chart/range", query: {
      vs_currency: "usd",
      from: from.to_i,
      to: to.to_i
    })
    response["prices"]
  rescue => e
    Rails.logger.error("Error fetching market_chart_range for #{coingecko_id}: #{e.message}")
    nil
  end

  private

  def self.fetch_from_market_chart_range(coingecko_id, time)
    from_timestamp = (time - 1.hour).to_i
    to_timestamp = (time + 1.hour).to_i

    response = get("/coins/#{coingecko_id}/market_chart/range", query: {
      vs_currency: "usd",
      from: from_timestamp,
      to: to_timestamp
    })

    prices = response["prices"]
    return nil if prices.blank?

    closest = prices.min_by { |ts, _| (ts / 1000 - time.to_i).abs }
    closest&.last
  rescue => e
    Rails.logger.error("Error fetching historical price (market_chart_range) for #{coingecko_id}: #{e.message}")
    nil
  end

  def self.fetch_from_history(coingecko_id, time)
    date_str = time.strftime("%d-%m-%Y")

    response = get("/coins/#{coingecko_id}/history", query: {
      date: date_str,
      localization: "false"
    })

    response.dig("market_data", "current_price", "usd")
  rescue => e
    Rails.logger.error("Error fetching historical price (history) for #{coingecko_id}: #{e.message}")
    nil
  end
end
