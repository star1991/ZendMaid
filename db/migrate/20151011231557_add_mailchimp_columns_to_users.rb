class AddMailchimpColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mailchimp_last_sync, :datetime
    add_column :users, :mailchimp_syncing, :boolean, :default => false
  end
end
