class AddColumnsTimeOptionsWeekdayOptionsToInstantBookingProfiles < ActiveRecord::Migration
  def change
    add_column :instant_booking_profiles, :time_options, :text
    add_column :instant_booking_profiles, :skip_days, :text
  end
end
