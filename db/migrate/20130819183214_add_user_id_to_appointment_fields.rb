class AddUserIdToAppointmentFields < ActiveRecord::Migration
  def change
    add_column :appointment_fields, :user_id, :integer
    add_index :appointment_fields, :user_id
  end
end
