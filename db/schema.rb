# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_11_152208) do
  create_table "coins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "coin_name"
    t.string "symbol"
    t.string "coingecko_id"
    t.decimal "fiat_balance", precision: 30, scale: 2, default: "0.0", null: false
    t.decimal "coin_balance", precision: 30, scale: 18, default: "0.0", null: false
    t.decimal "latest_price", precision: 30, scale: 18, default: "0.0", null: false
  end

  create_table "holdings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "coin_id"
    t.bigint "portfolio_id"
    t.decimal "coin_balance", precision: 30, scale: 18, default: "0.0"
    t.index ["coin_id", "portfolio_id"], name: "index_holdings_on_coin_id_and_portfolio_id", unique: true
    t.index ["coin_id"], name: "index_holdings_on_coin_id"
    t.index ["portfolio_id"], name: "index_holdings_on_portfolio_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "portfolio_name"
    t.string "description"
    t.decimal "fiat_balance", precision: 30, scale: 2, default: "0.0", null: false
    t.decimal "total_invested", precision: 30, scale: 2, default: "0.0", null: false
    t.decimal "profit_loss", precision: 30, scale: 2, default: "0.0", null: false
    t.decimal "profit_loss_percentage", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "coin_id"
    t.decimal "price", precision: 30, scale: 2
    t.datetime "recorded_at"
    t.index ["coin_id"], name: "index_prices_on_coin_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "coin_id"
    t.bigint "portfolio_id"
    t.string "action"
    t.datetime "time"
    t.string "memo"
    t.decimal "fiat_amount", precision: 30, scale: 2, default: "0.0"
    t.decimal "coin_amount", precision: 30, scale: 18, default: "0.0"
    t.index ["coin_id"], name: "index_transactions_on_coin_id"
    t.index ["portfolio_id"], name: "index_transactions_on_portfolio_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "username", default: "", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "holdings", "coins"
  add_foreign_key "holdings", "portfolios", on_delete: :cascade
  add_foreign_key "portfolios", "users"
  add_foreign_key "prices", "coins"
  add_foreign_key "transactions", "coins"
  add_foreign_key "transactions", "portfolios", on_delete: :cascade
end
