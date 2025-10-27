class Transaction < ApplicationRecord
  belongs_to :asset_record, class_name: 'Asset', foreign_key: :asset, primary_key: :name, optional: true

  validates :asset, presence: true
  validates :action, presence: true, inclusion: { in: %w[buy sell] }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :time, presence: true

  after_save :update_asset_balance
  before_destroy :reverse_transaction

  def to_s
    balance = Asset.find_by(name: asset)&.balance || 0
    "
    Asset: #{asset.downcase},
    Action: #{action.downcase},
    Amount: #{amount.to_s('F')},
    Balance: #{balance.to_s('F')},
    Time: #{time.strftime('%Y%m%d%H%M')}
    "
  end

  private

  def update_asset_balance
    reverse_old_transaction if saved_change_to_asset? || saved_change_to_action? || saved_change_to_amount?

    apply_transaction
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
end
