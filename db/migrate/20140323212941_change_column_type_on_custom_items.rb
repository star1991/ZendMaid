class ChangeColumnTypeOnCustomItems < ActiveRecord::Migration
  def up
    change_column :custom_items, :value_name, :text
    change_column :appointment_items, :value_name, :text
  end

  def down
    change_column :custom_items, :value_name, :string
    change_column :appointment_items, :value_name, :text
  end
end
