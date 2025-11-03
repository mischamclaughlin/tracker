class Portfolio < ApplicationRecord
  include PriceCalculations
  include PriceLookup

  self.primary_key = 'name'

  has_many :assets, foreign_key: :portfolio, primary_key: :name
  has_many :transactions, through: :assets
  has_many :prices, foreign_key: :asset, primary_key: :name

  validates :name, presence: true, uniqueness: true
  validates :balance_fiat, presence: true, numericality: true

  def to_s
    "
    Portfolio: #{name},
    Balance: #{balance_fiat.to_s('F')}
    ".squish
  end

  def self.find_or_create_for(portfolio_name)
    find_or_create_by(name: portfolio_name) do |portfolio|
      portfolio.balance_fiat = 0
    end
  end

  def recalculate_balance!
    # Sum all fiat values from transactions
    calculated_balance = Transaction.where(portfolio: name).sum("CASE WHEN action = 'buy' THEN -fiat WHEN action = 'sell' THEN fiat ELSE 0 END")
    update_column(:balance_fiat, calculated_balance.abs)
  end

  private

  def update_fiat_balance!
    price = current_price&.price || price_at(Time.now)
    new_balance_in_fiat = asset_to_fiat(balance_asset, price)
    update_column(:balance_fiat, new_balance_in_fiat)
  end
end
