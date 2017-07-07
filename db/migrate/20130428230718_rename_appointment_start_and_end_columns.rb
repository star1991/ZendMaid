class RenameAppointmentStartAndEndColumns < ActiveRecord::Migration
  def up
    rename_column :appointments, :start, :start_time
    rename_column :appointments, :end, :end_time
  end

  def down
    rename_column :appointments, :start_time, :start
    rename_column :appointments, :end_time, :end
  end
end
