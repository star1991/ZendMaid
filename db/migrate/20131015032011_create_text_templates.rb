class CreateTextTemplates < ActiveRecord::Migration
  def change
    create_table :text_templates do |t|
      t.text :body
      t.string :template_type
      t.integer :user_id
      t.integer :time_offset

      t.timestamps
    end
    
    add_index :text_templates, :user_id
  end
end
