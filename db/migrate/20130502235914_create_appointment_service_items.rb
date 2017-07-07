class CreateAppointmentServiceItems < ActiveRecord::Migration
  def change
    create_table :appointment_service_items do |t|
      t.integer :appointment_id
      t.integer :appointment_field_id
      t.integer :amount

      t.timestamps
    end
    
    add_index :appointment_service_items, :appointment_id
    add_index :appointment_service_items, :appointment_field_id
    add_index :appointment_service_items, [:appointment_id, :appointment_field_id], :unique => true, :name => 'index_appointment_service_items_on_both_foreign_ids'
  end
end
