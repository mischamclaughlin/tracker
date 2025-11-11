class Coin < ApplicationRecord
  include PriceCalculations
  include PriceLookup
  include SafeOrdering

  ALLOWED_COLUMNS = %w[symbol coin_name fiat_balance coin_balance latest_price].freeze unless const_defined?(:ALLOWED_COLUMNS)
  ALPHA_COLS = %w[symbol coin_name].freeze unless const_defined?(:ALPHA_COLS)

  has_many :transactions, foreign_key: 'coin_id', class_name: 'Transaction'
  has_many :holdings, foreign_key: 'coin_id', class_name: 'Holding'
  has_many :prices, foreign_key: 'coin_id', class_name: 'Price'

  validates :coin_name, presence: true, uniqueness: true
  validates :symbol, presence: true, uniqueness: true
  validates :coingecko_id, presence: true, uniqueness: true

  def to_s
    "
    Coin ID: #{id},
    Coin Name: #{coin_name},
    Coin Symbol: #{symbol},
    CoinGecko ID: #{coingecko_id},
    Created At: #{created_at.strftime('%d/%m/%Y %H:%M:%S')}
    ".squish
  end

  def self.find_by_symbol_or_name(identifier)
    key = identifier.downcase
    where('LOWER(symbol) = ? OR LOWER(coin_name) = ?', key, key).first
  end

  def self.search(identifier)
    key = identifier.to_s.downcase
    where('LOWER(symbol) LIKE ? OR LOWER(coin_name) LIKE ?', "%#{key}%", "%#{key}%")
  end

  def update_coin_metrics!
    update_columns(
      fiat_balance: calculate_balance_fiat,
      coin_balance: calculate_balance_coin,
      latest_price: fetch_current_price&.price
    )
  end

  private

  def fetch_current_price
    prices.order(recorded_at: :desc).first
  end

  def calculate_balance_coin
    holdings.sum(:coin_balance).to_d
  end

  def calculate_balance_fiat
    coin_to_fiat(calculate_balance_coin, fetch_current_price&.price).to_d
  end
end
