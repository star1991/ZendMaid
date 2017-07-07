class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.datetime :start, :null => false
      t.datetime :end, :null => false
      t.boolean :active, :default => true
      t.string :frequency
      t.integer :interval
      t.integer :customer_id

      t.timestamps
    end
    add_index :subscriptions, :customer_id
  end
end
