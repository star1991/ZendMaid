class AddTimesheetColumnsToAssignments < ActiveRecord::Migration
  def up
    add_column :assignments, :time_in, :datetime
    add_column :assignments, :time_out, :datetime
    add_column :assignments, :set_manually, :boolean, :default => false
    
    Assignment.reset_column_information
    Assignment.find_each do |assignment|
      assignment.update_column(:time_in, assignment.appointment.start_time)
      assignment.update_column(:time_out, assignment.appointment.end_time)
    end
  end
  
  def down
    remove_column :assignments, :time_in
    remove_column :assignments, :time_out
    remove_column :assignments, :set_manually
  end
end
