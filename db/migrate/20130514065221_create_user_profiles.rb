class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.integer :user_id
      t.string :company_email
      t.string :company_phone_number
      t.text :about_us
      t.string :company_name
      t.text :about_us
      
      t.timestamps
    end
    
    add_index :user_profiles, :user_id, :unique => true
  end
end
