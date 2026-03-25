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

ActiveRecord::Schema[8.1].define(version: 2026_03_24_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "timescaledb"

  create_table "temperature_readings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "raw_payload"
    t.datetime "recorded_at", null: false
    t.string "serial_port"
    t.string "source", default: "arduino", null: false
    t.float "temperature_c", null: false
    t.datetime "updated_at", null: false
    t.index ["recorded_at"], name: "index_temperature_readings_on_recorded_at"
  end
end
