class AddCallToActionToInstantBookingProfile < ActiveRecord::Migration
  def change
    add_column :instant_booking_profiles, :call_to_action, :string, default: "Book your Cleaning Instantly in 3 Easy Steps"
  end
end
