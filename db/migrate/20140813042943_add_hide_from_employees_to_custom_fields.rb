class AddHideFromEmployeesToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :hide_from_employees, :boolean, :default => false
  end
end
