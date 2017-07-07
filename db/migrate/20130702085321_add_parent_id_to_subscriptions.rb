class AddParentIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :parent_id, :integer
    add_index :subscriptions, :parent_id
  end
end
