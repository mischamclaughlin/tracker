module PriceCalculations
  extend ActiveSupport::Concern

  def fiat_to_asset(fiat_amount, price)
    return 0 if price.nil? || price.zero?
    fiat_amount / price
  end

  def asset_to_fiat(asset_amount, price)
    return 0 if price.nil?
    asset_amount * price
  end
end