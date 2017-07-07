class AddColumnActiveToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :active, :boolean, :default => true
    add_index :customers, :active
  end
end
