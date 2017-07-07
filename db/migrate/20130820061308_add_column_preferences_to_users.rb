class AddColumnPreferencesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :preferences, :text
  end
end
