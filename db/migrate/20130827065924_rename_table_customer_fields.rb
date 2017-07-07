class RenameTableCustomerFields < ActiveRecord::Migration
  
  class CustomerField < ActiveRecord::Base; end
  
  def up
    add_column :customer_fields, :field_type, :string
    add_index :customer_fields, :field_type
    
    CustomerField.reset_column_information
    CustomerField.update_all(:field_type => "customer")
    
    rename_table :customer_fields, :custom_fields
    
    
  end

  def down
    rename_table :custom_fields, :customer_fields
    
    remove_index :customer_fields, :field_type
    remove_column :customer_fields, :field_type
    
  end
end
