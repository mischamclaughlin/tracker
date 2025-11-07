class AddUniqueIndexToHolding < ActiveRecord::Migration[8.0]
  def change
    add_index :holdings, [:coin_id, :portfolio_id], unique: true, name: 'index_holdings_on_coin_id_and_portfolio_id'
  end
end
