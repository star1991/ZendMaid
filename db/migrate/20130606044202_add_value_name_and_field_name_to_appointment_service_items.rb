class AddValueNameAndFieldNameToAppointmentServiceItems < ActiveRecord::Migration
  def change
    add_column :appointment_service_items, :value_name, :string
    add_column :appointment_service_items, :field_name, :string
  end
end
