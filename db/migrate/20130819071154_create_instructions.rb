class CreateInstructions < ActiveRecord::Migration
  def change
    create_table :instructions do |t|
      t.integer :user_id
      t.string :field_name
      t.integer :order

      t.timestamps
    end
    
    add_index :instructions, :user_id
  end
end
