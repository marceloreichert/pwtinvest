class AddNameUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :full_name, :string, :limit => 40
  end

  def self.down
    drop_column :users, :full_name
  end
end
