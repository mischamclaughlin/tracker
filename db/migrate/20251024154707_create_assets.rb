class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.string :name
      t.decimal :balance, precision: 30, scale: 18

      t.timestamps
    end
  end
end
