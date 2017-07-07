class RenameColumnFieldIdToInstructionIdInAppointmentServiceItems < ActiveRecord::Migration
  def up
    remove_index :appointment_service_items, :appointment_field_id
    rename_column :appointment_service_items, :appointment_field_id, :instruction_id
    add_index :appointment_service_items, :instruction_id
    
  end

  def down
    remove_index :appointment_service_items, :instruction_id
    rename_column :appointment_service_items, :instruction_id, :appointment_field_id
    add_index :appointment_service_items, :appointment_field_id
  end
end
