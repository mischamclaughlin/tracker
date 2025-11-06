class CreateCoins < ActiveRecord::Migration[8.0]
  def change
    create_table :coins do |t|
      t.timestamps
    end
  end
end
