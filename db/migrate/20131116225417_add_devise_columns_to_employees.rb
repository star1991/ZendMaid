class AddDeviseColumnsToEmployees < ActiveRecord::Migration
  def change
    change_table :employees do |t|
      t.string :encrypted_password, :null => false, :default => '', :limit => 128
      
      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end
  
  end 
end
