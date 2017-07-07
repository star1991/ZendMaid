class CreateCustomerFields < ActiveRecord::Migration
  def change
    create_table :customer_fields do |t|
      t.integer :user_id
      t.string :field_name
      t.string :input_type
      t.text :value_names
      t.integer :order

      t.timestamps
    end
    
    add_index :customer_fields, :user_id
  end
end
