class CreatePapers < ActiveRecord::Migration
  def self.up
    create_table :papers do |t|
      t.string :symbol
      t.string :description
      t.integer :nr_lote

      t.timestamps
    end
  end

  def self.down
    drop_table :papers
  end
end
