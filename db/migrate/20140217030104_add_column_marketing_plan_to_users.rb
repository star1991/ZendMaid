class AddColumnMarketingPlanToUsers < ActiveRecord::Migration
  def change
    add_column :users, :marketing_plan, :boolean, :default => false
  end
end
