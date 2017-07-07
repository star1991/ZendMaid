class CreateCustomerItems < ActiveRecord::Migration
  def change
    create_table :customer_items do |t|
      t.integer :customer_id
      t.integer :customer_field_id
      t.string :value_name

      t.timestamps
    end
    
    add_index :customer_items, :customer_id
    add_index :customer_items, :customer_field_id
  end
end
