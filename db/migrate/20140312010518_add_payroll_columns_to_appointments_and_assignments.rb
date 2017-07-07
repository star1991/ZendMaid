class AddPayrollColumnsToAppointmentsAndAssignments < ActiveRecord::Migration
  def change
    add_column :appointments, :payroll_id, :integer
    add_index :appointments, :payroll_id
    
    add_column :assignments, :payroll_entry_id, :integer
    add_column :assignments, :job_wage, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :assignments, :extras, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :assignments, :total, :decimal, :precision => 8, :scale => 2, :default => 0
    add_index :assignments, :payroll_entry_id
    
    add_column :statuses, :use_for_payroll, :boolean, :default => true
    add_index :statuses, :use_for_payroll
  end
end
