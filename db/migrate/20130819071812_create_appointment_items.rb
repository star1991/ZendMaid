class CreateAppointmentItems < ActiveRecord::Migration
  def change
    create_table :appointment_items do |t|
      t.integer :appointment_id
      t.integer :appointment_field_id
      t.string :value_name

      t.timestamps
    end
    
    add_index :appointment_items, :appointment_id
    add_index :appointment_items, :appointment_field_id
  end
end
