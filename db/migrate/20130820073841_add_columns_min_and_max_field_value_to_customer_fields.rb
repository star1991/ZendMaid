class AddColumnsMinAndMaxFieldValueToCustomerFields < ActiveRecord::Migration
  def change
    add_column :customer_fields, :min_field_value, :integer, :default => 1
    add_column :customer_fields, :max_field_value, :integer
  end
end
