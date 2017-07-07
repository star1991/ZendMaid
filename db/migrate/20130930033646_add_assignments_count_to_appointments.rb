class AddAssignmentsCountToAppointments < ActiveRecord::Migration
  def up
    add_column :appointments, :assignments_count, :integer, :default => 0
    
    Appointment.reset_column_information
    Appointment.all.each do |a|
      Appointment.reset_counters(a.id, :assignments)
    end
  end
  
  def down
    remove_column :appointments, :assignments_count
  end
end
