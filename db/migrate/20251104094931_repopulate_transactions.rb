class RepopulateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.timestamps
    end
    add_column :transactions, :coin_id, :bigint
    add_column :transactions, :portfolio_id, :bigint
    add_column :transactions, :action, :string
    add_column :transactions, :time, :datetime
    add_column :transactions, :memo, :string
    add_column :transactions, :fiat_amount, :decimal, precision: 30, scale: 2, default: 0.0
    add_column :transactions, :coin_amount, :decimal, precision: 30, scale: 18, default: 0.0
    
    add_index :transactions, :coin_id
    add_index :transactions, :portfolio_id
    
    add_foreign_key :transactions, :coins, column: :coin_id
    add_foreign_key :transactions, :portfolios, column: :portfolio_id
  end
end
