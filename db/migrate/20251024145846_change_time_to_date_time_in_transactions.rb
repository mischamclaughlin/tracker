class ChangeTimeToDateTimeInTransactions < ActiveRecord::Migration[8.0]
  def change
    change_column :transactions, :time, :datetime
  end
end
