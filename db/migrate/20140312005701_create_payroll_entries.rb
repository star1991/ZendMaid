class CreatePayrollEntries < ActiveRecord::Migration
  def change
    create_table :payroll_entries do |t|
      t.integer :employee_id
      t.integer :payroll_id
      t.decimal :wage, :precision => 8, :scale => 2, :default => 0
      t.decimal :bonus, :precision => 8, :scale => 2, :default => 0
      t.decimal :deductions, :precision => 8, :scale => 2, :default => 0
      t.decimal :total_pay, :precision => 8, :scale => 2, :default => 0
      t.integer :assignments_count, :default => 0
      t.string :pay_type
      t.decimal :pay_rate, :precision => 8, :scale => 2

      t.timestamps
    end
    
    add_index :payroll_entries, :employee_id
    add_index :payroll_entries, :payroll_id
  end
end
