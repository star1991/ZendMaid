class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      
      t.references :user
      t.timestamps
    end
    
    add_index :customers, :email, :unique => true
    add_index :customers, :user_id
  end
end
