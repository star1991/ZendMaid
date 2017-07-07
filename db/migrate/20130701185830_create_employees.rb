class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.integer :user_id

      t.timestamps
    end
    add_index :employees, :user_id
  end
end
