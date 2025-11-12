class AddUniquenessToIndexPortolioUserId < ActiveRecord::Migration[8.0]
  def change
    add_index :portfolios, [:user_id, :portfolio_name], unique: true
  end
end
