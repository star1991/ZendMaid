class AddQbCustomerIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :qb_customer_id, :integer
    add_index :customers, :qb_customer_id
  end
end
