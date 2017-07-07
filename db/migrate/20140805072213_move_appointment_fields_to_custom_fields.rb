class MoveAppointmentFieldsToCustomFields < ActiveRecord::Migration
  def up
    AppointmentField.reset_column_information
    AppointmentItem.reset_column_information

    AppointmentField.all.each do |appointment_field|
      custom_field = CustomField.new(appointment_field.attributes.slice(*CustomField.accessible_attributes))
      custom_field.field_type = "appointment"
      custom_field.skip_after_create = true
      custom_field.save

      appointment_field.appointment_items.find_each do |appointment_item|
        custom_item = custom_field.custom_items.build(:value_name => appointment_item.value_name)
        custom_item.customizable_id = appointment_item.appointment_id
        custom_item.customizable_type = "Appointment"
        custom_item.save
      end
    end
  end

  def down
    CustomField.reset_column_information
    CustomField.where(:field_type => 'appointment').destroy_all
  end
end
