class AddUseForInvoiceToStatus < ActiveRecord::Migration
  def up
    add_column :statuses, :use_for_invoice, :boolean
    Status.reset_column_information
    Status.all.each do |status|
    	status.use_for_invoice = status.use_for_payroll
    	status.save!
    end
  end

  def down
  	remove_column :statuses, :use_for_invoice
  end
end
