class AddShowInGridToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :show_in_grid, :boolean, :default => true
  end
end
