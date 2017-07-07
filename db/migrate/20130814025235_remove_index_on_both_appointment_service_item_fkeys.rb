class RemoveIndexOnBothAppointmentServiceItemFkeys < ActiveRecord::Migration
  def up
    remove_index :appointment_service_items, :name => 'index_appointment_service_items_on_both_foreign_ids'
  end

  def down
    add_index :appointment_service_items, [:appointment_id, :appointment_field_id], :unique => true, :name => 'index_appointment_service_items_on_both_foreign_ids'
  end
end
