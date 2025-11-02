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

ActiveRecord::Schema[8.0].define(version: 2025_10_31_094956) do
  create_table "assets", force: :cascade do |t|
    t.string "name"
    t.decimal "balance", precision: 30, scale: 18
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_bought", precision: 30, scale: 18, default: "0.0"
    t.decimal "total_spent", precision: 30, scale: 2, default: "0.0"
    t.decimal "avg_buy_price", precision: 30, scale: 2, default: "0.0"
    t.decimal "total_sold", precision: 30, scale: 18, default: "0.0"
    t.decimal "total_received", precision: 30, scale: 2, default: "0.0"
    t.decimal "realised_pnl", precision: 30, scale: 2, default: "0.0"
    t.decimal "balance_in_fiat", precision: 30, scale: 2
    t.index ["balance_in_fiat"], name: "index_assets_on_balance_in_fiat"
  end

  create_table "prices", force: :cascade do |t|
    t.string "asset"
    t.decimal "price", precision: 30, scale: 18
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string "asset"
    t.string "action"
    t.datetime "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memo"
    t.decimal "amount", precision: 30, scale: 18
    t.decimal "price_at_time", precision: 30, scale: 18
    t.decimal "fiat", precision: 30, scale: 2
  end
end
