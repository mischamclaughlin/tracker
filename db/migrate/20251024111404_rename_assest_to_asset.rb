class RenameAssestToAsset < ActiveRecord::Migration[8.0]
  def change
    rename_column :transactions, :assest, :asset
  end
end
