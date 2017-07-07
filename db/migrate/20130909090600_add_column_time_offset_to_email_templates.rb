class AddColumnTimeOffsetToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :time_offset, :integer
  end
end
