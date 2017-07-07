class MoveReminderSentOnToSentOn < ActiveRecord::Migration
  def up
    Appointment.reset_column_information
    
    Appointment.all.each do |appointment|
      if appointment.reminder_sent_on.present?
        appointment.sent_on["Appointment Reminder Email"] = appointment.reminder_sent_on
        appointment.save!
      end
    end
    
    remove_column :appointments, :reminder_sent_on
    remove_column :appointments, :follow_up_sent_on
  end

  def down
    add_column :appointments, :follow_up_sent_on, :datetime
    add_column :appointments, :reminder_sent_on, :datetime
  end
end
