module PriceCalculations
  extend ActiveSupport::Concern

  def fiat_to_asset(fiat_amount, price)
    return 0 if price.nil? || price.zero?
    asset_amount = fiat_amount / price
    log_info("Converted fiat #{fiat_amount} at price #{price} to asset amount #{asset_amount}")
    asset_amount
  end

  def asset_to_fiat(asset_amount, price)
    return 0 if price.nil?
    fiat_amount = asset_amount * price
    log_info("Converted asset #{asset_amount} at price #{price} to fiat amount #{fiat_amount}")
    fiat_amount
  end
end
