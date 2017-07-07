class CreatePayrollAssignments < ActiveRecord::Migration
  def change
    create_table :payroll_assignments do |t|
      t.datetime :appointment_start_time
      t.text :customer_name
      t.integer :payroll_entry_id
      t.datetime :time_in
      t.datetime :time_out
      t.decimal :job_wage, :precision => 8, :scale => 2, :default => 0
      t.decimal :extras, :precision => 8, :scale => 2, :default => 0
      t.decimal :total, :precision => 8, :scale => 2, :default => 0
      t.decimal :appointment_revenue, :precision => 8, :scale => 2, :default => 0
      t.string :pay_type
      t.decimal :pay_rate, :precision => 8, :scale => 2

      t.timestamps
    end
    
    add_index :payroll_assignments, :payroll_entry_id
  end
end
