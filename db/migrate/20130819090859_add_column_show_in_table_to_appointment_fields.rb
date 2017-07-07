class AddColumnShowInTableToAppointmentFields < ActiveRecord::Migration
  def change
    add_column :appointment_fields, :show_in_table, :boolean, :default => false
  end
end
