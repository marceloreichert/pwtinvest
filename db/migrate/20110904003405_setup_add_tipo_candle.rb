class SetupAddTipoCandle < ActiveRecord::Migration
  def self.up
    add_column :setups, :first_candle_type, :string, :limit => 20
    add_column :setups, :second_candle_type, :string, :limit => 20
    add_column :setups, :third_candle_type, :string, :limit => 20    
  end

  def self.down
    drop_column :setups, :first_candle_type
    drop_column :setups, :second_candle_type
    drop_column :setups, :third_candle_type    
  end
end
