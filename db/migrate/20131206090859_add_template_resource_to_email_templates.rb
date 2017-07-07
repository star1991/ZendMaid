class AddTemplateResourceToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :template_resource, :string, :default => "Appointment"
    add_index :email_templates, :template_resource
  end
end
