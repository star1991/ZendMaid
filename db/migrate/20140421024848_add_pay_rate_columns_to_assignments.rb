class AddPayRateColumnsToAssignments < ActiveRecord::Migration
  def up
    add_column :assignments, :pay_type, :string
    add_column :assignments, :pay_rate, :decimal
  
    Assignment.reset_column_information
    PayrollEntry.reset_column_information
    
    PayrollEntry.all.each do |entry|
      entry.assignments.each do |assignment|
        assignment.pay_type = entry.pay_type
        assignment.pay_rate = entry.pay_rate
        assignment.save
      end
    end
  end
  
  def down
    remove_column :assignments, :pay_type
    remove_column :assignments, :pay_rate
  end
end
