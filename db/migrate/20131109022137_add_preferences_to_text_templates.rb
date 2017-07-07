class AddPreferencesToTextTemplates < ActiveRecord::Migration
  def change
    add_column :text_templates, :preferences, :text
  end
end
