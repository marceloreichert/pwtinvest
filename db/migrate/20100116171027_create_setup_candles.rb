class CreateSetupCandles < ActiveRecord::Migration
  def self.up
    create_table :setup_candles do |t|
      t.integer :setup_id
      t.string :type_candle
      t.string :candle_position

      t.timestamps
    end
  end

  def self.down
    drop_table :setup_candles
  end
end
