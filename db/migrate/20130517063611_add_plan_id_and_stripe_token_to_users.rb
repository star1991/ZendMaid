class AddPlanIdAndStripeTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :plan_id, :string
    add_column :users, :stripe_customer_token, :string
  end
end
