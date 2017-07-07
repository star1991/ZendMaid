class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.integer :user_id
      t.text :title
      t.text :body
      t.string :template_type
      t.boolean :active, :default => true

      t.timestamps
    end
    
    add_index :email_templates, :user_id
    add_index :email_templates, :template_type
  end
end
