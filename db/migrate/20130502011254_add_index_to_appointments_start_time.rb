class AddIndexToAppointmentsStartTime < ActiveRecord::Migration
  def up
    add_index :appointments, :start_time
  end
  
  def down
    remove_index :appointments, :start_time
  end
end
