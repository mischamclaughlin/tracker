class BackfillPricesService
  include LoggingModule

  # Public entry point to backfill prices for a coin between time range.
  # resolution: :daily or :hourly
  def run(coin:, from:, to:, resolution: :hourly)
    return if coin.blank? || from.blank? || to.blank?

    if resolution == :daily
      backfill_daily(coin, from: from, to: to)
    else
      backfill_hourly_range(coin, from: from, to: to)
    end
  end

  private

  def backfill_daily(coin, from:, to:)
    days = [ (to.to_date - from.to_date).to_i + 1, 1 ].max
    prices = CoingeckoService.fetch_market_chart_days(coin.coingecko_id, days: [ days, 365 ].min, interval: "daily")
    return log_error("No daily prices returned for #{coin.coingecko_id}") if prices.blank?

    rows = prices.map do |(ts_ms, price)|
      ts = Time.at(ts_ms.to_i / 1000).utc.beginning_of_day
      { coin_id: coin.id, price: BigDecimal(price.to_s), recorded_at: ts }
    end

    upsert_rows(rows)
  end

  # Fetch hourly-ish samples in chunks using market_chart/range
  def backfill_hourly_range(coin, from:, to:)
    chunk_days = 30
    start_time = from
    while start_time < to
      end_time = [ start_time + chunk_days.days, to ].min
      prices = CoingeckoService.fetch_market_chart_range(coin.coingecko_id, from: start_time, to: end_time)
      if prices.present?
        rows = prices.map do |(ts_ms, price)|
          ts = Time.at(ts_ms.to_i / 1000).utc.change(min: 0, sec: 0)
          { coin_id: coin.id, price: BigDecimal(price.to_s), recorded_at: ts }
        end
        upsert_rows(rows)
      else
        log_error("No range prices returned for #{coin.coingecko_id} from #{start_time} to #{end_time}")
      end
      start_time = end_time
    end
  end

  def upsert_rows(rows)
    return if rows.blank?
    # Deduplicate within-batch on recorded_at
    deduped = rows.uniq { |r| [ r[:coin_id], r[:recorded_at] ] }
    Price.upsert_all(deduped, unique_by: :index_prices_on_coin_id_and_recorded_at)
    log_info("Upserted #{deduped.size} price points")
  rescue => e
    log_error("Failed to upsert prices: #{e.message}")
  end
end
