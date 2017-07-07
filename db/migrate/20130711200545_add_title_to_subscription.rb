class AddTitleToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :title, :string
  end
end
