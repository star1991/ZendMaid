class AddImportedToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :imported, :boolean,:default => false
  end
end