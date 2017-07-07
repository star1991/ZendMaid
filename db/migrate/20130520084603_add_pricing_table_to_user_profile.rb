class AddPricingTableToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :pricing_table, :hstore
  end
end
