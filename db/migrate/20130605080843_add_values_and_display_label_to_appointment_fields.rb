class AddValuesAndDisplayLabelToAppointmentFields < ActiveRecord::Migration
  def change
    add_column :appointment_fields, :value_names, :text
    add_column :appointment_fields, :pricing_table_id, :integer
    add_column :appointment_fields, :display_label, :boolean, :default => true
  end
end
