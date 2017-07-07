class RenameTableCustomerItems < ActiveRecord::Migration
  
  class CustomerItem < ActiveRecord::Base; end
  
  def up
    remove_index :customer_items, :customer_field_id
    rename_column :customer_items, :customer_field_id, :custom_field_id
    add_index :customer_items, :custom_field_id
    
    remove_index :customer_items, :customer_id
    rename_column :customer_items, :customer_id, :customizable_id
    add_column :customer_items, :customizable_type, :string
    add_index :customer_items, [:customizable_type, :customizable_id], :name => "index_custom_items_on_polymorphic"
    
    CustomerItem.reset_column_information
    CustomerItem.update_all(:customizable_type => "Customer")
    
    
    
    rename_table :customer_items, :custom_items
    
  end

  def down
    rename_table :custom_items, :customer_items
    
    remove_index :customer_items, :name => "index_custom_items_on_polymorphic"
    remove_column :customer_items, :customizable_type
    rename_column :customer_items, :customizable_id, :customer_id
    add_index :customer_items, :customer_id
    
    remove_index :customer_items, :custom_field_id
    rename_column :customer_items, :custom_field_id, :customer_field_id
    add_idex :customer_items, :customer_field_id
    
    
  end
end
