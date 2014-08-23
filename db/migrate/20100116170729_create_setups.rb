class CreateSetups < ActiveRecord::Migration
  def self.up
    create_table :setups do |t|
      t.string :setup
      t.string :description
      t.integer :quantity_candle
      t.string :fl_rel_candle
      t.string :first_candle, :default => "N"
      t.string :second_candle, :default => "N"
      t.string :third_candle, :default => "N"
      t.integer :user_id      

      t.timestamps
    end
  end

  def self.down
    drop_table :setups
  end
end
