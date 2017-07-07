class RenameNotesToRequestsInAppointments < ActiveRecord::Migration
  def change
    rename_column :appointments, :notes, :requests
  end
end
