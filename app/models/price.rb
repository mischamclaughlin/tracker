class Price < ApplicationRecord
  belongs_to :coin, foreign_key: :coin_id, class_name: 'Coin'

  validates :coin_id, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :recorded_at, presence: true

  after_create :update_prices
  after_update :update_prices

  def to_s
    "
    Coin ID: #{coin.id},
    Price: $#{price.to_s('F')},
    Recorded At: #{recorded_at.strftime('%d/%m/%Y %H:%M:%S')}
    ".squish
  end

  def update_prices
    update_portfolios_metrics
    update_coins_metrics
  end

  def self.price_for_coin_exists?(coin_id, recorded)
    return false if coin_id.blank? || recorded.blank?
    where(coin_id: coin_id).where('recorded_at <= ?', recorded).exists?
  end

  private

  def update_portfolios_metrics
    portfolios = Portfolio.joins(holdings: :coin).where(coins: { id: coin_id }).distinct
    portfolios.each do |portfolio|
      portfolio.update_portfolio_metrics!
      log_info("Updated Portfolio ID: #{portfolio.id} metrics after Price ID: #{id} change")
    end
  end

  def update_coins_metrics
    coin.update_coin_metrics!
    log_info("Updated Coin ID: #{coin.id} metrics after Price ID: #{id} change")
  end
end
