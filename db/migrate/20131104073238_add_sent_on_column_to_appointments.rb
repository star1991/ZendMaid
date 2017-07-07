class AddSentOnColumnToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :sent_on, :text
  end
end
