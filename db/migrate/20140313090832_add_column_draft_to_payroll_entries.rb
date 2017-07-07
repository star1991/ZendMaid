class AddColumnDraftToPayrollEntries < ActiveRecord::Migration
  def change
    add_column :payroll_entries, :draft, :boolean, :default => true
    add_column :payroll_entries, :full_name, :string
    
    add_column :payrolls, :out_of_date, :boolean, :default => false
  end
end
