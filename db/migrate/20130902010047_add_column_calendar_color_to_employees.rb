class AddColumnCalendarColorToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :calendar_color, :string, :default => "#026b9c"
  end
end
