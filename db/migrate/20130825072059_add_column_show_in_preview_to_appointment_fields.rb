class AddColumnShowInPreviewToAppointmentFields < ActiveRecord::Migration
  def change
    add_column :appointment_fields, :show_in_preview, :boolean, :default => false
    
    add_index :appointment_fields, :show_in_preview
    add_index :appointment_fields, :show_in_table
  end
end
