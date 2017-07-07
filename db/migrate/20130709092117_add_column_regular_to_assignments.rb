class AddColumnRegularToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :regular, :boolean, :default => false
    add_index :assignments, :regular
  end
end
