class Asset < ApplicationRecord
  self.primary_key = 'name'

  has_many :transactions, foreign_key: :asset, primary_key: :name
  has_many :prices, foreign_key: :asset, primary_key: :name

  validates :name, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: true

  def self.find_or_create_for(asset_name)
    find_or_create_by(name: asset_name) do |asset|
      asset.balance = 0
    end
  end

  def recalculate_balance!
    calculated_balance = transactions.sum("CASE WHEN action = 'buy' THEN amount WHEN action = 'sell' THEN -amount ELSE 0 END")
    update_column(:balance, calculated_balance)
  end

  def current_price
    prices.order(recorded_at: :desc).first
  end

  def price_at(time)
    prices.where('recorded_at <= ?', time).order(recorded_at: :desc).first&.price
  end
end
