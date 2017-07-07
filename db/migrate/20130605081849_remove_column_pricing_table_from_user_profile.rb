class RemoveColumnPricingTableFromUserProfile < ActiveRecord::Migration
  def up
    remove_column :user_profiles, :pricing_table
  end

  def down
    add_column :user_profiles, :pricing_table, :hstore
  end
end
