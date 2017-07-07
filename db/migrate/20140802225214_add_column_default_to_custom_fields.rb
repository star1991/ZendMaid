class AddColumnDefaultToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :default, :text
  end
end
