class AddColumnUseAsPrototypeToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :use_as_prototype, :boolean, :default => true
  end
end
