class DeleteInstantBookingProfileColumnsFromOtherModels < ActiveRecord::Migration
  def up
    remove_index :users, :subdomain
    remove_column :users, :subdomain
    remove_column :users, :advance_booking_days 
    remove_column :users, :default_appointment_length
    
    remove_column :user_profiles, :about_us
    remove_column :user_profiles, :embed
    remove_column :user_profiles, :custom_css
    
  end

  def down
    add_column :users, :subdomain, :string
    add_column :users, :advance_booking_days, :integer, :default => 1
    add_column :users, :default_appointment_length, :integer, :default => 3
    add_index :users, :subdomain, :unique => true
    
    add_column :user_profiles, :about_us, :text
    add_column :user_profiles, :embed, :boolean, :default => false
    add_column :user_profiles, :custom_css, :text 
  end
end
