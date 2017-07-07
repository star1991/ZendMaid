class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :subscription_id
      t.datetime :start
      t.datetime :end
      t.boolean :paid, :default => false
      t.boolean :cancelled, :default => false
      t.boolean :assigned, :default => false

      t.timestamps
    end
    add_index :appointments, :subscription_id
  end
end
