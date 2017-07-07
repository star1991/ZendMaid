class CreatePayrolls < ActiveRecord::Migration
  def change
    create_table :payrolls do |t|
      t.integer :user_id
      t.integer :payroll_number
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :draft, :default => true
      t.decimal :total_pay, :precision => 8, :scale => 2, :default => 0
      t.integer :appointments_count, :default => 0
      t.integer :payroll_entries_count, :default => 0

      t.timestamps
    end
    
    add_column :users, :last_used_payroll_number, :integer, :default => 0
    
    add_index :payrolls, :user_id
  end
end
