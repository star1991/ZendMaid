class CreateInstantBookingProfiles < ActiveRecord::Migration
  def change
    create_table :instant_booking_profiles do |t|
      t.integer :user_id
      t.string :subdomain
      t.integer :advance_booking_days, :default => 1
      t.integer :default_appointment_length, :default => 3
      t.boolean :embed, :default => false
      t.text :custom_css
      t.text :about_us
      
      t.timestamps
    end
    
    add_index :instant_booking_profiles, :subdomain, :unique => true
    add_index :instant_booking_profiles, :user_id, :unique => true
  end
  
end
