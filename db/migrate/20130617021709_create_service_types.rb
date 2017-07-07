class CreateServiceTypes < ActiveRecord::Migration
  def up
    create_table :service_types do |t|
      t.integer :user_id, :null => false
      t.string :name
      
      t.timestamps
    end
    
    add_index :service_types, :user_id
    remove_column :appointment_fields, :user_id
    
    add_column :appointment_fields, :service_type_id, :integer
    add_index :appointment_fields, :service_type_id
    
    add_column :appointments, :service_type_id, :integer
    add_index :appointments, :service_type_id
  end
  
  def down
    remove_index :service_types, :user_id
    drop_table :service_types
    
    remove_index :appointment_fields, :service_type_id
    remove_column :appointment_fields, :service_type_id
    
    add_column :appointment_fields, :user_id, :integer
    
    remove_index :appointments, :service_type_id
    remove_column :appointments, :service_type_id
  end
end
