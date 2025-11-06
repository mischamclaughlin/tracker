class DropAllTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :transactions, if_exists: true
    drop_table :assets, if_exists: true
    drop_table :portfolios, if_exists: true
  end
end
