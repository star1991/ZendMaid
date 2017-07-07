class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :appointment_id
      t.integer :employee_id
      t.string :role

      t.timestamps
    end
    
    add_index :assignments, [:employee_id, :appointment_id], :unique => true, :name => "index_assignments_on_associations"
  end
end
