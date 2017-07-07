class CreateTeamsEmployees < ActiveRecord::Migration
  def change
    create_table :teams_employees do |t|
      t.integer :team_id
      t.integer :employee_id

      t.timestamps
    end
    
    add_index :teams_employees, :team_id
    add_index :teams_employees, :employee_id
  end
end
