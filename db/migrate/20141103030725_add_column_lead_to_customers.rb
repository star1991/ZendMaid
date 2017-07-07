class AddColumnLeadToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :lead, :boolean, :default => true
  end
end
