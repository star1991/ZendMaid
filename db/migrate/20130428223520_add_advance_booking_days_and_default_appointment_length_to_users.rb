class AddAdvanceBookingDaysAndDefaultAppointmentLengthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :advance_booking_days, :integer, :default => 1
    add_column :users, :default_appointment_length, :integer, :default => 3
  end
end
