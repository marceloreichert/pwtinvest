class CreateDailyQuotations < ActiveRecord::Migration
  def self.up
    create_table :daily_quotations do |t|
      t.string :paper, :limit => 10
      t.date :date_quotation
      t.decimal :open, :precision => 13, :scale => 2
      t.decimal :close, :precision => 13, :scale => 2
      t.decimal :high, :precision => 13, :scale => 2
      t.decimal :low, :precision => 13, :scale => 2
      t.decimal :volume, :precision => 13, :scale => 2
      t.string :type_candle, :limit => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :daily_quotations
  end
end
