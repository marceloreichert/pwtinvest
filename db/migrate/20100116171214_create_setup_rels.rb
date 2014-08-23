class CreateSetupRels < ActiveRecord::Migration
  def self.up
    create_table :setup_rels do |t|
      t.integer :setup_id
      t.string :candle_x_value
      t.string :candle_x_position
      t.string :value
      t.string :candle_y_value
      t.string :candle_y_position

      t.timestamps
    end
  end

  def self.down
    drop_table :setup_rels
  end
end
