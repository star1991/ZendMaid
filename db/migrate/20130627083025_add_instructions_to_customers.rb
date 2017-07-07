class AddInstructionsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :instructions, :text
  end
end
