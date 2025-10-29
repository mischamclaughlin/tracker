class Price < ApplicationRecord
  belongs_to :asset_record, class_name: 'Asset', foreign_key: :asset, primary_key: :name

  validates :asset, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :recorded_at, presence: true

  scope :recent, -> { order(recorded_at: :desc) }
  scope :for_asset, ->(asset_name) { where(asset: asset_name) }
end
