class AddColumnsActiveToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :active, :boolean, :default => true
    add_column :employees, :inactivated_on, :datetime
  end
end
