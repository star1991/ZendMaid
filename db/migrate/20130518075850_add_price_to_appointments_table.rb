class AddPriceToAppointmentsTable < ActiveRecord::Migration
  def change
    add_column :appointments, :price, :decimal, :precision => 8, :scale => 2
  end
end
