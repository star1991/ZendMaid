class AddAppointmentFieldColumnsToCustomFields < ActiveRecord::Migration
  def up
    add_column :custom_fields, :pricing_table_id, :integer
    add_column :custom_fields, :show_in_table, :boolean, :default => false
    add_column :custom_fields, :unique, :boolean, :default => false
    add_column :custom_fields, :show_in_preview, :boolean, :default => false
  
    add_index :custom_fields, :pricing_table_id
  end

  def down
    remove_column :custom_fields, :pricing_table_id
    remove_column :custom_fields, :show_in_table
    remove_column :custom_fields, :unique
    remove_column :custom_fields, :show_in_preview  
    
    remove_index :custom_fields, :pricing_table_id
  end
end
