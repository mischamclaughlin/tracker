class AddUserIdToPortfolio < ActiveRecord::Migration[8.0]
  def change
    add_column :portfolios, :user_id, :bigint

    add_index :portfolios, :user_id

    add_foreign_key :portfolios, :users, column: :user_id
  end
end
