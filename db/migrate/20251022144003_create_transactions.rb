class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :assest
      t.string :action
      t.date :time

      t.timestamps
    end
  end
end
