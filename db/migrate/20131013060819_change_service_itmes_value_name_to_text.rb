class ChangeServiceItmesValueNameToText < ActiveRecord::Migration
  def up
    change_column :appointment_service_items, :value_name, :text
  end

  def down
    change_column :appointment_service_items, :value_name, :string
  end
end
