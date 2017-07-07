class CreateTaskRecurrences < ActiveRecord::Migration
  def change
    create_table :task_recurrences do |t|
      t.text :schedule
      t.integer :user_id
      t.text :task
      t.text :note

      t.timestamps
    end

    add_column :tasks, :task_recurrence_id, :integer

    add_index :tasks, :task_recurrence_id
    add_index :task_recurrences, :user_id
  end
end
