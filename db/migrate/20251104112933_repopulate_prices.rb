class RepopulatePrices < ActiveRecord::Migration[8.0]
  def change
    create_table :prices do |t|
      t.timestamps
    end
    add_column :prices, :coin_id, :bigint
    add_column :prices, :price, :decimal, precision: 30, scale: 18, default: 0.0
    add_column :prices, :recorded_at, :datetime
  end
end
