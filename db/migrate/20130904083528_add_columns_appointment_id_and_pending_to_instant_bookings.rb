class AddColumnsAppointmentIdAndPendingToInstantBookings < ActiveRecord::Migration
  def change
    add_column :instant_bookings, :pending, :boolean, :default => true
    add_column :instant_bookings, :appointment_id, :integer
    
    add_index :instant_bookings, :pending
  end
end
