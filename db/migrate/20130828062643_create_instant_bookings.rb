class CreateInstantBookings < ActiveRecord::Migration
  def change
    create_table :instant_bookings do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :email
      t.datetime :start_time
      t.decimal :price, :precision => 8, :scale => 2
      t.integer :service_type_id
      t.text :requests

      t.timestamps
    end
    
    add_index :instant_bookings, :service_type_id
    
    add_column :custom_fields, :service_type_id, :integer
    add_column :custom_fields, :price, :decimal, :precision => 8, :scale => 2
    add_index :custom_fields, :service_type_id
    
    add_column :pricing_tables, :custom_field_ids, :text
  end
end
