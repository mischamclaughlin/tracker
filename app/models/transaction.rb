class Transaction < ApplicationRecord
  include PriceCalculations
  include SafeOrdering

  ALLOWED_COLUMNS = %w[time fiat amount].freeze

  belongs_to :asset_record, class_name: 'Asset', foreign_key: :asset, primary_key: :name, optional: true

  validates :asset, presence: true
  validates :action, presence: true, inclusion: { in: %w[buy sell] }
  validates :time, presence: true
  validates :amount, numericality: { greater_than: 0 }, allow_nil: true
  validates :fiat, numericality: { greater_than: 0 }, allow_nil: true
  validate :ensure_amount_or_fiat_provided

  before_validation :normalise_attributes, on: :create
  before_validation :clean_empty_values
  before_validation :fetch_historical_price
  before_validation :compute_missing_field
  after_save :update_asset_balance
  after_save :update_asset_metrics
  before_destroy :reverse_transaction
  before_destroy :schedule_metrics_update

  scope :search_by_asset, ->(asset_name) { where(asset: asset_name) }
  scope :order_by_time, -> { order(time: :desc) }
  scope :order_by_asset_balance, -> { order(amount: :desc) }
  scope :order_by_fiat_balance, -> { order(fiat: :desc) }

  def to_s
    balance = Asset.find_by(name: asset)&.balance || 0
    "
    Asset: #{asset},
    Action: #{action},
    Amount: #{amount.to_s('F')},
    Balance: #{balance.to_s('F')},
    Time: #{time.strftime('%Y%m%d%H%M')}
    ".squish
  end

  private

  def normalise_attributes
    self.asset = asset.upcase.strip if asset.present?
    self.action = action.downcase.strip if action.present?
    self.memo = memo.strip if memo.present?
  end

  def clean_empty_values
    self.amount = nil if amount.to_s.strip.empty? || amount.to_f.zero? || amount.blank?
    self.fiat = nil if fiat.to_s.strip.empty? || fiat.to_f.zero? || fiat.blank?
    log_info("After clean_empty_values: [amount: #{amount}, type: #{amount.class}, fiat: #{fiat}, type: #{fiat.class}]")
  end

  def fetch_historical_price
    return if price_at_time.present?
    return unless asset.present?

    asset_obj = Asset.find_or_create_by(name: asset) do |a|
      a.balance = 0
    end

    local_price = asset_obj.price_at(time)
    self.price_at_time = local_price&.price

    if price_at_time.nil? && asset_obj.coingecko_id.present?
      self.price_at_time = CoingeckoService.fetch_historical_price(
        asset_obj.coingecko_id,
        time
      )
    end
  end

  def compute_missing_field
    log_info("Compute Start: [amount: #{amount.inspect}, fiat: #{fiat.inspect}, price_at_time: #{price_at_time.inspect}]")
    return unless price_at_time.present?

    amount_present = amount.present? && amount.to_f > 0
    fiat_present = fiat.present? && fiat.to_f > 0

    if !amount_present && fiat_present
      self.amount = fiat_to_asset(fiat, price_at_time)
    elsif amount_present && !fiat_present
      self.fiat = asset_to_fiat(amount, price_at_time)
    end

    log_info("Compute End: [amount: #{amount.inspect}, fiat: #{fiat.inspect}]")
  end

  def update_asset_balance
    reverse_old_transaction if previously_persisted? && (saved_change_to_asset? || saved_change_to_action? || saved_change_to_amount?)
    apply_transaction
  end

  def update_asset_metrics
    asset_record = Asset.find_or_create_for(asset)
    asset_record.recalculate_metrics!
  end

  def reverse_transaction
    asset_record = Asset.find_by(name: asset)

    return unless asset_record

    case action
    when 'buy'
      asset_record.decrement!(:balance, amount)
    when 'sell'
      asset_record.increment!(:balance, amount)
    end
  end

  def schedule_metrics_update
    @asset_for_metrics_update = asset
  end

  def reverse_old_transaction
    old_asset = saved_change_to_asset? ? asset_before_last_save : asset
    asset_record = Asset.find_by(name: old_asset)

    return unless asset_record
    
    old_action = saved_change_to_action? ? action_before_last_save : action
    old_amount = saved_change_to_amount? ? amount_before_last_save : amount

    case old_action
    when 'buy'
      asset_record.decrement!(:balance, old_amount)
    when 'sell'
      asset_record.increment!(:balance, old_amount)
    end
  end

  def apply_transaction
    asset_record = Asset.find_or_create_for(asset)

    case action
    when 'buy'
      asset_record.increment!(:balance, amount)
    when 'sell'
      asset_record.decrement!(:balance, amount)
    end
  end

  def previously_persisted?
    !saved_change_to_id?
  end

  def ensure_amount_or_fiat_provided
    amount_present = amount.present? && amount.to_f > 0
    fiat_present = fiat.present? && fiat.to_f > 0
    log_info("Validation Check: [amount_valid: #{amount_present}, fiat_valid: #{fiat_present}]")

    unless amount_present || fiat_present
      errors.add(:base, 'Either amount or fiat value must be provided.')
    end
  end
end
