class AddColumnsToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :use_for_conflicts, :boolean, :default => true
    add_column :statuses, :show_in_work_orders, :boolean, :default => true
  
    add_index :statuses, :use_for_conflicts
    add_index :statuses, :show_in_work_orders
  end

end
