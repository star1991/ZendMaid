class AddColumnPreferencesToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :preferences, :text
    
    add_column :appointments, :follow_up_sent_on, :datetime
  end
end
