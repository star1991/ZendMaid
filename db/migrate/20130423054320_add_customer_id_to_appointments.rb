class AddCustomerIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :customer_id, :integer
    add_index :appointments, :customer_id
  end
end
