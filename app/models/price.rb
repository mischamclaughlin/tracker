class Price < ApplicationRecord
  belongs_to :asset_record, class_name: 'Asset', foreign_key: :asset, primary_key: :name

  validates :asset, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :recorded_at, presence: true

  after_save :update_asset

  scope :recent, -> { order(recorded_at: :desc) }
  scope :for_asset, ->(asset_name) { where(asset: asset_name) }

  def to_s
    "
    Asset: #{asset},
    Price: $#{price.to_s('F')},
    Recorded At: #{recorded_at.strftime('%Y-%m-%d %H:%M:%S')}
    ".squish
  end

  private

  def update_asset
    asset_record&.recalculate_balance!
  end
end
