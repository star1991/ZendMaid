class AddAllowEnterTimeToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :allow_enter_time, :boolean, :default => false
  end
end
