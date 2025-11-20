class AddUniqueIndexToPricesOnCoinAndRecordedAt < ActiveRecord::Migration[7.1]
  def up
    # Deduplicate existing rows so the unique index can be created safely.
    # Policy: keep the latest row (by id) for each [coin_id, recorded_at].
    execute <<~SQL
      DELETE FROM prices
      WHERE id IN (
        SELECT p.id
        FROM prices p
        JOIN (
          SELECT coin_id, recorded_at, MAX(id) AS keep_id
          FROM prices
          GROUP BY coin_id, recorded_at
        ) d
        ON p.coin_id = d.coin_id AND p.recorded_at = d.recorded_at
        WHERE p.id <> d.keep_id
      );
    SQL

    add_index :prices, [:coin_id, :recorded_at], unique: true, name: :index_prices_on_coin_id_and_recorded_at
  end

  def down
    remove_index :prices, name: :index_prices_on_coin_id_and_recorded_at
  end
end
