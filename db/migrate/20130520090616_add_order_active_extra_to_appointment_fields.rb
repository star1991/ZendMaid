class AddOrderActiveExtraToAppointmentFields < ActiveRecord::Migration
  def change
    add_column :appointment_fields, :order, :integer, :null => false, :default => 1
    add_column :appointment_fields, :active, :boolean, :default => true
    add_column :appointment_fields, :extra, :boolean, :default => true
  end
end
