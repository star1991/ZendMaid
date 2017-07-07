class AddIndexesToAssignments < ActiveRecord::Migration
  def up
    remove_index :assignments, :regular
    remove_column :assignments, :regular
    
    add_index :assignments, :appointment_id
    add_index :assignments, :employee_id
  end
  
  def down
    add_column :assignments, :regular, :boolean
    add_index :assignments, :regular
    
    remove_index :assignments, :appointment_id
    remove_index :assignments, :employee_id
  end
end
