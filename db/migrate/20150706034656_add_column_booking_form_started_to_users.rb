class AddColumnBookingFormStartedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :booking_form_started, :boolean, :default => false
  end
end
