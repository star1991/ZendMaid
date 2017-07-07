class RenameStartAndEndInSubscriptions < ActiveRecord::Migration
  def up
    rename_column :subscriptions, :start, :start_time
    rename_column :subscriptions, :end, :end_time
    add_index :subscriptions, :start_time
  end

  def down
    remove_index :subscriptions, :start_time
    rename_column :subscriptions, :start_time, :start
    rename_column :subscriptions, :end_time, :end
  end
end
