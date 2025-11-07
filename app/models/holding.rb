class Holding < ApplicationRecord
  belongs_to :coin, foreign_key: 'coin_id', class_name: 'Coin'
  belongs_to :portfolio, foreign_key: 'portfolio_id', class_name: 'Portfolio'

  validates :coin_id, uniqueness: { scope: :portfolio_id }
  validates :portfolio_id, uniqueness: { scope: :coin_id }
  validates :coin_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def to_s
    "
    Coin: #{coin.id},
    Portfolio: #{portfolio.id},
    Coin Balance: #{coin_balance.to_s('F')}
    ".squish
  end

  def current_fiat_value
    coin_balance * (coin.current_price || 0)
  end

  def total_fiat_invested
    buys = transactions.where(transaction_type: 'buy').sum(:fiat_value)
    sells = transactions.where(transaction_type: 'sell').sum(:fiat_value)
    total_invested = buys - sells
    log_info("Total Fiat Invested Calculation - Buys: #{buys}, Sells: #{sells}, Total Invested: #{total_invested}")
    total_invested
  end

  def profit_loss
    current_fiat_value - total_fiat_invested
  end
end
