class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :user_id
      t.text :task
      t.text :note
      t.date :due_date
      t.date :completed_on

      t.timestamps
    end
    
    add_index :tasks, :user_id
  end
end
