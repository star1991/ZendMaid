class AddQuickbooksIntegrationColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :qb_access_token, :string
    add_column :users, :qb_access_secret, :string
    add_column :users, :qb_company_id, :string
    add_column :users, :qb_token_expires_at, :datetime
    add_column :users, :qb_reconnect_token_at, :datetime
  end
end
