class AddColumnShowInBookingToServiceTypes < ActiveRecord::Migration
  def change
    add_column :service_types, :show_in_booking, :boolean, :default => true
  end
end
