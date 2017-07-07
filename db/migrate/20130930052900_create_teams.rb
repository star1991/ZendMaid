class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :user_id
      t.string :name
      t.string :calendar_color, :default => "#026b9c"
      
      t.timestamps
    end
    
    add_column :appointments, :team_id, :integer
    
    add_index :teams, :user_id
    add_index :appointments, :team_id
        
  end
end
