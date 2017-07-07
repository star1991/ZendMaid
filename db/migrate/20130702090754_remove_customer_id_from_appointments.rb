class RemoveCustomerIdFromAppointments < ActiveRecord::Migration
  def up
    remove_index :appointments, :customer_id
    remove_column :appointments, :customer_id
  end

  def down
    add_column :appointments, :customer_id, :integer
    add_index :appointments, :customer_id
  end
end
