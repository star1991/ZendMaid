class CreateLogEntries < ActiveRecord::Migration
  def change
    create_table :log_entries do |t|
      t.integer :appointment_id
      t.string :log_type
      t.text :entry
      t.text :note

      t.timestamps
    end
    
    add_index :log_entries, :appointment_id
    add_index :log_entries, :created_at
  end
end
