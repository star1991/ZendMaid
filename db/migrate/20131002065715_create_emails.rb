class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :address
      t.string :email_type
      t.boolean :primary
      t.boolean :send_automated, :default => true
      
      t.references :emailable, :polymorphic => true
      
      t.timestamps
    end
    
    add_index :emails, [:emailable_id, :emailable_type], :name => "index_emails_polymorphic"
  end
end
