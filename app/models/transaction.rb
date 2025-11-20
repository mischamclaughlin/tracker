class Transaction < ApplicationRecord
  include PriceCalculations
  include SafeOrdering

  ALLOWED_COLUMNS = %w[time fiat_amount coin_amount].freeze unless const_defined?(:ALLOWED_COLUMNS)
  ALPHA_COLS = %w[].freeze unless const_defined?(:ALPHA_COLS)

  attr_accessor :coin_identifier, :portfolio_identifier

  belongs_to :coin, foreign_key: "coin_id", class_name: "Coin"
  belongs_to :portfolio, foreign_key: "portfolio_id", class_name: "Portfolio"

  validates :coin_id, presence: true
  validates :portfolio_id, presence: true
  validates :action, presence: true, inclusion: { in: %w[buy sell transfer] }
  validates :time, presence: true
  validates :fiat_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :coin_amount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :normalise_attributes, on: :create
  before_validation :ensure_coin_exists, on: :create
  before_validation :ensure_portfolio_exists, on: :create
  before_validation :ensure_date_exists, on: :create
  before_validation :ensure_amount_provided, on: :create

  before_validation :ensure_date_exists, on: :update, if: :will_save_change_to_time? || :will_save_change_to_coin_id?
  before_validation :derive_coin_from_change, on: :update, if: -> { coin_identifier.present? }
  before_validation :derive_amounts_from_change, on: :update, if: :amounts_time_or_coin_changed?

  after_create :update_holding_balances
  after_create :update_portfolio_metrics
  after_create :update_coin_metrics
  after_update :reverse_old_and_apply_new_transaction
  after_update :update_portfolio_metrics
  after_update :update_coin_metrics
  after_destroy :reverse_transaction_from_holding
  after_destroy :update_coin_metrics
  after_destroy :update_portfolio_metrics

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

  def self.search(identifier)
    key = identifier.to_s.downcase
    joins(:coin, :portfolio).where("LOWER(coins.symbol) = ? OR LOWER(coins.coin_name) = ? OR LOWER(portfolios.portfolio_name) LIKE ?", key, key, "%#{key}%")
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

  def ensure_date_exists
    return errors.add(:time, "Time must be within the last 365 days.") if time < 1.year.ago
    log_info("Checking existence of Price for Coin ID: #{coin_id} at Recorded At: #{time}")
    data = Price.price_for_coin_exists?(coin_id, time)
    if data
      log_info("Price data exists for Coin ID: #{coin_id} at Time: #{time}")
    else
      log_error("Price data missing for Coin ID: #{coin_id} at Time: #{time}")
      # Enqueue a small window backfill so subsequent requests have data locally
      BackfillPricesJob.perform_later(coin_id, (time - 1.day), (time + 1.day))

      # Fallback: fetch a single price now and upsert to avoid unique constraint races
      historical_price = CoingeckoService.fetch_historical_price(coin.coingecko_id, time)
      if historical_price
        Price.upsert_all([
          { coin_id: coin_id, price: historical_price, recorded_at: time }
        ], unique_by: :index_prices_on_coin_id_and_recorded_at)
        log_info("Fetched and upserted historical price for Coin ID: #{coin_id} at Time: #{time}")
      else
        errors.add(:time, "No price data available for the specified time: #{time}")
        log_error("Failed to fetch historical price for Coin ID: #{coin_id} at Time: #{time}")
      end
    end
  end

  def ensure_amount_provided
    log_info("Validating Amounts: [FIAT AMOUNT: #{fiat_amount}, TYPE: #{fiat_amount.class}], [COIN AMOUNT: #{coin_amount}, TYPE: #{coin_amount.class}]")
    if fiat_amount.zero? && coin_amount.zero?
      errors.add(:base, "Either fiat amount or coin amount must be provided and greater than zero.")
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

  def derive_coin_from_change
    rec = Coin.find_by_symbol_or_name(coin_identifier.strip)
    return errors.add(:coin_identifier, "Coin with identifier '#{coin_identifier}' does not exist.") unless rec

    self.coin_id = rec.id
  end

  def amounts_time_or_coin_changed?
    will_save_change_to_fiat_amount? || will_save_change_to_coin_amount? || will_save_change_to_time? || will_save_change_to_coin_id?
  end

  def derive_amounts_from_change
    ensure_date_exists
    price = coin_price_at(time)&.price
    if price.nil? || price.zero?
      log_error("Price Lookup Failed: Cannot recalculate amounts due to missing price data at Time: #{time}")
      return
    end

    fiat_changed = will_save_change_to_fiat_amount?
    coin_changed = will_save_change_to_coin_amount?
    time_changed = will_save_change_to_time?
    coin_id_changed = will_save_change_to_coin_id?

    if fiat_changed && !coin_changed
      self.coin_amount = fiat_to_coin(fiat_amount, price)
      log_info("Recalculated Coin Amount: #{coin_amount} from Fiat Amount: #{fiat_amount} at Time Change: #{time} (price: #{price})")
    elsif coin_changed && !fiat_changed
      self.fiat_amount = coin_to_fiat(coin_amount, price)
      log_info("Recalculated Fiat Amount: #{fiat_amount} from Coin Amount: #{coin_amount} at Time Change: #{time} (price: #{price})")
    elsif time_changed || coin_id_changed
      self.coin_amount = fiat_to_coin(fiat_amount, price)
      log_info("Recalculated Coin Amount: #{coin_amount} from Fiat Amount: #{fiat_amount} due to #{time_changed ? 'Time' : 'Coin'} Change: #{time} (price: #{price})")
    else
      expected = fiat_to_coin(fiat_amount, price)
      if (coin_amount - expected).abs > 0.0000001
        self.coin_amount = expected
        log_info("Adjusted Coin Amount: #{coin_amount} to match Fiat Amount: #{fiat_amount} at Time: #{time} (price: #{price})")
      end
    end
  end

  # ========================================================================= #

  # ================================= AFTER ================================= #

  def update_holding_balances
    holding = find_or_create_holding

    case action
    when "buy"
      holding.increment!(:coin_balance, coin_amount)
    when "sell"
      holding.decrement!(:coin_balance, coin_amount)
    end
  end

  def reverse_old_and_apply_new_transaction
    return unless saved_change_to_action? || saved_change_to_coin_amount? || saved_change_to_fiat_amount? || saved_change_to_coin_id? || saved_change_to_portfolio_id? || saved_change_to_time?

    old_coin_id = saved_change_to_coin_id? ? coin_id_before_last_save : coin_id
    old_portfolio_id = saved_change_to_portfolio_id? ? portfolio_id_before_last_save : portfolio_id
    old_action = saved_change_to_action? ? action_before_last_save : action
    old_fiat_amount = saved_change_to_fiat_amount? ? fiat_amount_before_last_save : fiat_amount
    old_coin_amount = saved_change_to_coin_amount? ? coin_amount_before_last_save : coin_amount
    log_info("Reversing old transaction: [OLD COIN ID: #{old_coin_id}, OLD PORTFOLIO ID: #{old_portfolio_id}, OLD ACTION: #{old_action}, OLD FIAT AMOUNT: #{old_fiat_amount}, OLD COIN AMOUNT: #{old_coin_amount}]")
    reverse_transaction_amounts(old_coin_id, old_portfolio_id, old_action, old_fiat_amount, old_coin_amount)

    ensure_date_exists
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
    when "buy"
      holding.decrement!(:coin_balance, old_coin_amount)
      log_info("Reversed old 'buy' transaction: Decremented Coin Balance by #{old_coin_amount} for Holding [Coin ID: #{old_coin_id}, Portfolio ID: #{old_portfolio_id}]")
    when "sell"
      holding.increment!(:coin_balance, old_coin_amount)
      log_info("Reversed old 'sell' transaction: Incremented Coin Balance by #{old_coin_amount} for Holding [Coin ID: #{old_coin_id}, Portfolio ID: #{old_portfolio_id}]")
    end
  end

  def update_coin_metrics
    coin.update_coin_metrics!
    log_info("Updated Coin ID: #{coin.id} metrics after Transaction ID: #{id} change")
  end

  def update_portfolio_metrics
    portfolio.update_portfolio_metrics!
    log_info("Updated Portfolio ID: #{portfolio.id} metrics after Transaction ID: #{id} change")
  end

  # =========================================================================== #

  # ================================= HELPERS ================================= #

  def find_coin_amount_from_fiat
    price = coin_price_at(time)&.price
    if price.nil? || price.zero?
      errors.add(:base, "Unable to determine coin amount: price data is unavailable.")
      log_error("Price Lookup Failed: Cannot calculate coin amount from fiat amount #{fiat_amount}")
      return
    end

    self.coin_amount = fiat_to_coin(fiat_amount, price)
    log_info("Calculated Coin Amount: #{coin_amount} from Fiat Amount: #{fiat_amount} at Price: #{price}")
  end

  def find_fiat_amount_from_coin
    price = coin_current_price&.price || coin_price_at(time)&.price
    if price.nil?
      errors.add(:base, "Unable to determine fiat amount: price data is unavailable.")
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
