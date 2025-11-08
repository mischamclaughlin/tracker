class Portfolio < ApplicationRecord
  has_many :transactions, foreign_key: 'portfolio_id', class_name: 'Transaction'
  has_many :holdings, foreign_key: 'portfolio_id', class_name: 'Holding'

  validates :portfolio_name, presence: true, uniqueness: true

  def to_s
    "
    Portfolio ID: #{id},
    Portfolio Name: #{portfolio_name},
    Portfolio Description: #{description},
    Portfolio Created At: #{created_at.strftime('%d/%m/%Y %H:%M:%S')}
    ".squish
  end

  def total_coin_balance_for(coin)
    holding = holdings.find_by(coin_id: coin.id)
    holding ? holding.coin_balance : 0
  end

  def current_value
    holdings.includes(:coin).sum do |holding|
      price = holding.coin.current_price&.price || 0
      holding.coin_balance * price
    end
  end

  def total_fiat_invested
    buys = transactions.where(action: 'buy').sum(:fiat_amount)
    sells = transactions.where(action: 'sell').sum(:fiat_amount)
    buys - sells
  end

  def profit_loss
    current_value - total_fiat_invested
  end

  def profit_loss_percentage
    return 0 if total_fiat_invested.zero?

    (profit_loss / total_fiat_invested * 100).round(2)
  end
end
