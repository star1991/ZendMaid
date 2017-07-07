class AddColumnShowPriceToInstantBookingProfile < ActiveRecord::Migration
  def change
    add_column :instant_booking_profiles, :show_price, :boolean, :default => true
    add_column :instant_booking_profiles, :show_about_us, :boolean, :default => true
    add_column :instant_booking_profiles, :compact, :boolean, :default => false
    add_column :instant_booking_profiles, :font_urls, :text
    add_column :instant_booking_profiles, :button_color_class, :string
  end
end
