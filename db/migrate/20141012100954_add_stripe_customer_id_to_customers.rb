class AddStripeCustomerIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :stripe_customer_id, :string
  end
end
