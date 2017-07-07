class ConvertOldApprovedPayrollsToNewSchema < ActiveRecord::Migration
  def up
    Payroll.reset_column_information
    
    Payroll.where(:draft => false).each do |payroll|
      payroll.approve!
    end
  end

  def down
  end
end
