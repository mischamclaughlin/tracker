class Price < ApplicationRecord
  belongs_to :coin, foreign_key: :coin_id, class_name: 'Coin'

  def to_s
    "
    Coin ID: #{coin.id},
    Price: $#{price.to_s('F')},
    Recorded At: #{recorded_at.strftime('%d/%m/%Y %H:%M:%S')}
    ".squish
  end
end
