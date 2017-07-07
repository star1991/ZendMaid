class AddMissingAppointmentItemsToAppointments < ActiveRecord::Migration
  def up

    Appointment.reset_column_information
    User.all.each do |user|
      if user.appointment_fields.size > 0
        
        user.appointments.find_each do |appointment|
          (user.appointment_fields.map(&:id) - appointment.appointment_items.map(&:custom_field_id)).each do |id|
            appointment.appointment_items.build(:custom_field_id => id)
          end

          appointment.save
        end
      
      end
    end

  end

  def down
  end
end
