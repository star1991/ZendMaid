class AddTimeZoneAndPhoneNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :time_zone, :string, :default => "Pacific Time (US & Canada)"
    add_column :users, :phone_number, :string
  end
end
