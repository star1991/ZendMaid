class AddColumnMarketingPlanToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :marketing_plan, :boolean, :default => false
  end
end
