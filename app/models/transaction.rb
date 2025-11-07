class Transaction < ApplicationRecord
  include PriceCalculations
  include SafeOrdering

  ALLOWED_COLUMNS = %w[time fiat_amount coin_amount].freeze unless const_defined?(:ALLOWED_COLUMNS)

  attr_accessor :coin_identifier, :portfolio_identifier

  belongs_to :coin, foreign_key: 'coin_id', class_name: 'Coin'
  belongs_to :portfolio, foreign_key: 'portfolio_id', class_name: 'Portfolio'

  validates :coin_id, presence: true
  validates :portfolio_id, presence: true
  validates :action, presence: true, inclusion: { in: %w[buy sell transfer] }
  validates :time, presence: true
  validates :fiat_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :coin_amount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :normalise_attributes, on: :create
  before_validation :ensure_coin_exists, on: :create
  before_validation :ensure_portfolio_exists, on: :create
  before_validation :ensure_amount_provided, on: :create
  
  after_create :update_holding_balances
  after_update :reverse_old_and_apply_new_transaction
  after_destroy :reverse_transaction_from_holding

  delegate :current_price, :price_at, to: :coin, prefix: :coin, allow_nil: true

  def to_s
    "
    Transaction ID: #{id},
    Coin ID: #{coin.id},
    Portfolio ID: #{portfolio.id},
    Action: #{action},
    Time: #{time.strftime('%d/%m/%Y %H:%M:%S')},
    Memo: #{memo},
    Fiat Amount: $#{fiat_amount.to_s('F')},
    Coin Amount: #{coin_amount.to_s('F')},
    ".squish
  end

  def coin_information
    Coin.find_by(id: coin_id)
  end

  def portfolio_information
    Portfolio.find_by(id: portfolio_id)
  end

  private

  # ================================= BEFORE ================================= #

  def normalise_attributes
    self.action = action.downcase.strip if action.present?
    self.memo = memo.strip if memo.present?
  end

  def ensure_coin_exists
    return if coin_id.present?
    return unless coin_identifier.present?
    coin_identifier.strip!
    
    coin_record = Coin.find_by_symbol_or_name(coin_identifier)
    unless coin_record
      errors.add(:coin_identifier, "Coin with identifier '#{coin_identifier}' does not exist.")
      log_error("Coin Lookup Failed for identifier: #{coin_identifier}")
      # get notification to update coins
      return
    end

    self.coin_id = coin_record.id
    log_info("Coin Lookup Succeeded: #{coin_identifier} -> ID: #{coin_record.id}")
  end

  def ensure_portfolio_exists
    return if portfolio_id.present?
    return unless portfolio_identifier.present?
    portfolio_identifier.strip!

    portfolio_record = Portfolio.find_or_initialize_by(portfolio_name: portfolio_identifier)
    if portfolio_record.new_record?
      portfolio_record.save!
      log_info("Created new Portfolio with name: #{portfolio_identifier}")
    else
      log_info("Found existing Portfolio with name: #{portfolio_identifier}")
    end

    self.portfolio_id = portfolio_record.id
    log_info("Portfolio Lookup Succeeded: #{portfolio_identifier} -> ID: #{portfolio_record.id}")
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:portfolio_identifier, "Could not create portfolio: #{e.message}")
    log_error("Portfolio Creation Failed for identifier: #{portfolio_identifier} - #{e.message}")
  end

  def ensure_amount_provided
    if fiat_amount.zero? && coin_amount.zero?
      errors.add(:base, 'Either fiat amount or coin amount must be provided and greater than zero.')
      log_error("Amount Validation Failed: [FIAT AMOUNT: #{fiat_amount}, COIN AMOUNT: #{coin_amount}]")
    end
    log_info("Amount Validation Passed: [FIAT AMOUNT: #{fiat_amount}, COIN AMOUNT: #{coin_amount}]")

    if coin_amount.zero? && fiat_amount.nonzero?
      find_coin_amount_from_fiat
    end

    if fiat_amount.zero? && coin_amount.nonzero?
      find_fiat_amount_from_coin
    end
  end

  # ========================================================================= #
  
  # ================================= AFTER ================================= #

  def update_holding_balances
    holding = find_or_create_holding

    case action
    when 'buy'
      holding.increment!(:coin_balance, coin_amount)
    when 'sell'
      holding.decrement!(:coin_balance, coin_amount)
    end
  end

  def reverse_old_and_apply_new_transaction
    return unless saved_change_to_action? || saved_change_to_coin_amount? || saved_change_to_fiat_amount? || saved_change_to_coin_id? || saved_change_to_portfolio_id?

    old_coin_id = saved_change_to_coin_id? ? coin_id_before_last_save : coin_id
    old_portfolio_id = saved_change_to_portfolio_id? ? portfolio_id_before_last_save : portfolio_id
    old_action = saved_change_to_action? ? action_before_last_save : action
    old_fiat_amount = saved_change_to_fiat_amount? ? fiat_amount_before_last_save : fiat_amount
    old_coin_amount = saved_change_to_coin_amount? ? coin_amount_before_last_save : coin_amount
    reverse_transaction_amounts(old_coin_id, old_portfolio_id, old_action, old_fiat_amount, old_coin_amount)
    
    ensure_amount_provided
    update_holding_balances
  end

  def reverse_transaction_from_holding
    reverse_transaction_amounts(coin_id, portfolio_id, action, fiat_amount, coin_amount)
  end

  def reverse_transaction_amounts(old_coin_id, old_portfolio_id, old_action, old_fiat_amount, old_coin_amount)
    holding = Holding.find_by(coin_id: old_coin_id, portfolio_id: old_portfolio_id)
    return unless holding

    case old_action
    when 'buy'
      holding.decrement!(:coin_balance, old_coin_amount)
      log_info("Reversed old 'buy' transaction: Decremented Coin Balance by #{old_coin_amount} for Holding [Coin ID: #{old_coin_id}, Portfolio ID: #{old_portfolio_id}]")
    when 'sell'
      holding.increment!(:coin_balance, old_coin_amount)
      log_info("Reversed old 'sell' transaction: Incremented Coin Balance by #{old_coin_amount} for Holding [Coin ID: #{old_coin_id}, Portfolio ID: #{old_portfolio_id}]")
    end
  end

  # =========================================================================== #
  
  # ================================= HELPERS ================================= #
  
  def find_coin_amount_from_fiat
    price = coin_current_price&.price || coin_price_at(time)&.price
    if price.nil? || price.zero?
      errors.add(:base, 'Unable to determine coin amount: price data is unavailable.')
      log_error("Price Lookup Failed: Cannot calculate coin amount from fiat amount #{fiat_amount}")
      return
    end

    self.coin_amount = fiat_to_coin(fiat_amount, price)
    log_info("Calculated Coin Amount: #{coin_amount} from Fiat Amount: #{fiat_amount} at Price: #{price}")
  end

  def find_fiat_amount_from_coin
    price = coin_current_price&.price || coin_price_at(time)&.price
    if price.nil?
      errors.add(:base, 'Unable to determine fiat amount: price data is unavailable.')
      log_error("Price Lookup Failed: Cannot calculate fiat amount from coin amount #{coin_amount}")
      return
    end

    self.fiat_amount = coin_to_fiat(coin_amount, price)
    log_info("Calculated Fiat Amount: #{fiat_amount} from Coin Amount: #{coin_amount} at Price: #{price}")
  end

  def find_or_create_holding
    holding = Holding.find_or_initialize_by(coin_id: coin_id, portfolio_id: portfolio_id)
    if holding.new_record?
      holding.save!
      log_info("Created new Holding for Coin ID #{coin_id} and Portfolio ID #{portfolio_id}")
      return holding
    end

    log_info("Found existing Holding for Coin ID #{coin_id} and Portfolio ID #{portfolio_id}")
    holding
  rescue ActiveRecord::RecordNotUnique
    log_info("Holding already exists for Coin ID #{coin_id} and Portfolio ID #{portfolio_id}")
    Holding.find_by!(coin_id: coin_id, portfolio_id: portfolio_id)
  end
end
