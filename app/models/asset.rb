class Asset < ApplicationRecord
  include PriceCalculations
  include PriceLookup
  include SafeOrdering

  ALLOWED_COLUMNS = %w[balance_in_fiat balance].freeze

  self.primary_key = 'name'

  has_many :transactions, foreign_key: :asset, primary_key: :name
  has_many :prices, foreign_key: :asset, primary_key: :name

  validates :name, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: true
  validates :balance_in_fiat, presence: true, numericality: true

  scope :search_by_asset, ->(asset_name) { where(name: asset_name) }
  scope :order_by_fiat_balance, -> { order(balance_in_fiat: :desc) }
  scope :order_by_asset_balance, -> { order(balance: :desc) }

  def to_s
    "
    Asset: #{name},
    Balance: #{balance.to_s('F')}
    ".squish
  end

  def to_param
    name
  end

  def self.find_or_create_for(asset_name)
    find_or_create_by(name: asset_name) do |asset|
      asset.balance = 0
      asset.balance_in_fiat = 0
    end
  end

  def recalculate_balance!
    recalculate_balance(transactions, :balance)
    update_fiat_balance!
  end

  def recalculate_metrics!
    buy_txs = transactions.where(action: 'buy')
    sell_txs = transactions.where(action: 'sell')

    new_total_bought = buy_txs.sum(:amount)
    new_total_spent = buy_txs.sum(:fiat)
    new_avg_buy_price = new_total_bought.zero? ? 0 : (new_total_spent / new_total_bought)

    new_total_sold = sell_txs.sum(:amount)
    new_total_received = sell_txs.sum(:fiat)

    new_realised_pnl = sell_txs.sum do |sell|
      avg_at_sell_time = calculate_avg_buy_price_at(sell.time)
      (sell.price_at_time - avg_at_sell_time) * sell.amount
    end

    update_columns(
      total_bought: new_total_bought,
      total_spent: new_total_spent,
      avg_buy_price: new_avg_buy_price,
      total_sold: new_total_sold,
      total_received: new_total_received,
      realised_pnl: new_realised_pnl
    )
  end

  def unrealised_pnl
    return 0 if balance.zero? || avg_buy_price.zero?
    current = current_price&.price || 0
    (current - avg_buy_price) * balance
  end

  def unrealised_pnl_percentage
    return 0 if avg_buy_price.zero?
    current = current_price&.price || 0
    ((current - avg_buy_price) / avg_buy_price) * 100
  end

  def total_pnl
    realised_pnl + unrealised_pnl
  end

  def coingecko_id
    COINGECKO_MAPPING[name]
  end

  def price_trackable?
    coingecko_id.present?
  end
  
  private
  
  def update_fiat_balance!
    price = current_price&.price || price_at(Time.now)
    new_balance_in_fiat = asset_to_fiat(balance, price)
    update_column(:balance_in_fiat, new_balance_in_fiat)
  end

  def calculate_avg_buy_price_at(time)
    buys = transactions.where(action: 'buy').where('time <= ?', time)
    return 0 if buys.empty?

    total_spent = buys.sum(:fiat)
    total_bought = buys.sum(:amount)
    
    total_bought.zero? ? 0 : (total_spent / total_bought)
  end
end
