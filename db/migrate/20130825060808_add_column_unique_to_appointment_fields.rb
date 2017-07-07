class AddColumnUniqueToAppointmentFields < ActiveRecord::Migration
  def change
    add_column :appointment_fields, :unique, :boolean, :default => false
  end
end
