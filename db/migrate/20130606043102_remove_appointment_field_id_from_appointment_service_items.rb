class RemoveAppointmentFieldIdFromAppointmentServiceItems < ActiveRecord::Migration
  def up
    remove_column :appointment_service_items, :amount
  end

  def down
    add_column :appointment_service_items, :amount, :integer
  end
end
