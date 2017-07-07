class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :name
      t.integer :user_id
      t.integer :order
      t.string :calendar_color, :default => "#026b9c"
      
      t.timestamps
    end
    
    add_index :statuses, :user_id
    
    add_column :appointments, :status_id, :integer
    add_index :appointments, :status_id
  end
end
