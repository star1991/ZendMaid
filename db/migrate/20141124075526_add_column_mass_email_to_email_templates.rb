class AddColumnMassEmailToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :mass_email, :boolean, :default => false
  end
end
