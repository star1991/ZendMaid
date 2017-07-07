class AddNoteToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :notes, :text
    add_column :appointments, :confirmed, :boolean, :default => false
  end
end
