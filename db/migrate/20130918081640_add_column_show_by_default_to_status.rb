class AddColumnShowByDefaultToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :show_by_default, :boolean, :default => true
  end
end
