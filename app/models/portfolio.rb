class Portfolio < ApplicationRecord
  include SafeOrdering

  ALLOWED_COLUMNS = %w[portfolio_name fiat_balance total_invested profit_loss profit_loss_percentage].freeze unless const_defined?(:ALLOWED_COLUMNS)
  ALPHA_COLS = %w[portfolio_name].freeze unless const_defined?(:ALPHA_COLS)

  has_many :transactions, foreign_key: 'portfolio_id', class_name: 'Transaction'
  has_many :holdings, foreign_key: 'portfolio_id', class_name: 'Holding'

  validates :portfolio_name, presence: true, uniqueness: true

  scope :search_by_portfolio_name, ->(name) { where('LOWER(portfolio_name) LIKE ?', "%#{name.downcase}%") if name.present? }

  def to_s
    "
    Portfolio ID: #{id},
    Portfolio Name: #{portfolio_name},
    Portfolio Description: #{description},
    Portfolio Created At: #{created_at.strftime('%d/%m/%Y %H:%M:%S')}
    ".squish
  end

  def update_portfolio_metrics!
    update_columns(
      fiat_balance: calculate_current_value,
      total_invested: calculate_total_fiat_invested,
      profit_loss: calculate_profit_loss,
      profit_loss_percentage: calculate_profit_loss_percentage
    )
  end

  private

  def calculate_current_value
    holdings.includes(:coin).sum do |holding|
      price = holding.coin.current_price&.price || 0
      holding.coin_balance * price
    end
  end

  def calculate_total_fiat_invested
    buys = transactions.where(action: 'buy').sum(:fiat_amount)
    sells = transactions.where(action: 'sell').sum(:fiat_amount)
    buys - sells
  end

  def calculate_profit_loss
    calculate_current_value - calculate_total_fiat_invested
  end

  def calculate_profit_loss_percentage
    return 0 if calculate_total_fiat_invested.zero?

    (calculate_profit_loss / calculate_total_fiat_invested * 100).round(2)
  end
end
