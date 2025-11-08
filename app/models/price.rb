class Price < ApplicationRecord
  belongs_to :coin, foreign_key: :coin_id, class_name: 'Coin'

  validates :coin_id, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :recorded_at, presence: true

  after_create :update_portfolio_prices
  after_update :update_portfolio_prices

  def to_s
    "
    Coin: #{coin.id},
    Price: $#{price.to_s('F')},
    Recorded At: #{recorded_at.strftime('%d/%m/%Y %H:%M:%S')}
    ".squish
  end

  def update_portfolio_prices
    portfolios = Portfolio.joins(holdings: :coin).where(coins: { id: coin_id }).distinct
    portfolios.each do |portfolio|
      portfolio.update_metrics!
      log_info("Updated Portfolio ID: #{portfolio.id} due to Price change for Coin ID: #{coin_id}")
    end
  end
end
