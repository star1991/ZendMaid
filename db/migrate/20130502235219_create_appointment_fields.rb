class CreateAppointmentFields < ActiveRecord::Migration
  def change
    create_table :appointment_fields do |t|
      t.integer :user_id
      t.string :field_name
      t.string :input_type
      t.decimal :price, :precision => 8, :scale => 2
      t.integer :max_field_value
      t.integer :min_field_value, :default => 1

      t.timestamps
    end
    
    add_index :appointment_fields, :user_id
  end
end
