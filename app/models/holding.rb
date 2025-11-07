class Holding < ApplicationRecord
  belongs_to :coin, foreign_key: 'coin_id', class_name: 'Coin'
  belongs_to :portfolio, foreign_key: 'portfolio_id', class_name: 'Portfolio'

  validates :coin_id, uniqueness: { scope: :portfolio_id }
  validates :portfolio_id, uniqueness: { scope: :coin_id }
  validates :coin_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def to_s
    "
    Holding ID: #{id},
    Coin: #{coin.id},
    Portfolio: #{portfolio.id},
    Coin Balance: #{coin_balance.to_s('F')}
    ".squish
  end
end
