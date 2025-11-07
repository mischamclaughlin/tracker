module PriceLookup
  extend ActiveSupport::Concern

  def current_price
    prices.order(recorded_at: :desc).first
  end

  def price_at(time)
    prices.where('recorded_at <= ?', time).order(recorded_at: :desc).first
  end
end
