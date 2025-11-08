class Coin < ApplicationRecord
  include PriceCalculations
  include PriceLookup

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
end
