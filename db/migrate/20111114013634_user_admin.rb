class UserAdmin < ActiveRecord::Migration
  def self.up
    add_column :users, :fl_admin, :boolean
  end

  def self.down
    drop_column :users, :fl_admin
  end
end
