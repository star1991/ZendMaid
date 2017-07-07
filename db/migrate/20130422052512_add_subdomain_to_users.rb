class AddSubdomainToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subdomain, :string
    add_index :users, :subdomain, :unique => true
  end
end
