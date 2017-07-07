class AddUserPermissionsColumnsToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :owner, :boolean, :default => false
    add_column :employees, :assignable, :boolean, :default => true
    add_column :employees, :admin, :boolean, :default => false
  end
end
