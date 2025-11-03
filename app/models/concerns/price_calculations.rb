module PriceCalculations
  extend ActiveSupport::Concern

  def fiat_to_asset(fiat_amount, price)
    return 0 if price.nil? || price.zero?
    asset_amount = fiat_amount / price
    log_info("🔄 Converted FIAT: #{fiat_amount} at price $#{price} to asset amount #{asset_amount}")
    asset_amount
  end

  def asset_to_fiat(asset_amount, price)
    return 0 if price.nil?
    fiat_amount = asset_amount * price
    log_info("🔄 Converted ASSET: #{asset_amount} at price $#{price} to fiat amount #{fiat_amount}")
    fiat_amount
  end

  def recalculate_balance(targets, column)
    calculated_balance = targets.sum("CASE WHEN action = 'buy' THEN amount WHEN action = 'sell' THEN -amount ELSE 0 END")
    update_column(column, calculated_balance)
    log_info("🔄 Recalculated balance for Asset: #{name}, New Balance: #{calculated_balance}")
  end
end
