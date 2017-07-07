class AddApiTokenAndPlanToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :stripe_customer_token, :string
    add_column :leads, :plan_id, :string
  end
end
