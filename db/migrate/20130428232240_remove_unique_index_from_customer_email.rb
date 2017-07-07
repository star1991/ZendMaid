class RemoveUniqueIndexFromCustomerEmail < ActiveRecord::Migration
  def up
    remove_index :customers, :column => :email
    add_index :customers, :email
  end

  def down
    remove_index :customers, :column => :email
    add_index :customers, :email, :unique => true
  end
end
