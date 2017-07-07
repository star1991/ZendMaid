class AddQbSyncingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :qb_syncing, :boolean, :default => false
    add_column :users, :qb_last_sync, :datetime
  end
end
