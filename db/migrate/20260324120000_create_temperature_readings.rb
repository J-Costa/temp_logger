class CreateTemperatureReadings < ActiveRecord::Migration[8.1]
  def change
    create_table :temperature_readings do |t|
      t.float :temperature_c, null: false
      t.datetime :recorded_at, null: false
      t.string :source, null: false, default: "arduino"
      t.string :serial_port
      t.text :raw_payload

      t.timestamps
    end

    add_index :temperature_readings, :recorded_at
  end
end
