class CreatePricingTables < ActiveRecord::Migration
  def change
    create_table :pricing_tables do |t|
      t.integer :user_id
      t.string :name
      t.text :pricing_table

      t.timestamps
    end
    
    add_index :pricing_tables, :user_id
  end
end
