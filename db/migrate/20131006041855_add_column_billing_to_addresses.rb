class AddColumnBillingToAddresses < ActiveRecord::Migration
  def up
    add_column :addresses, :billing, :boolean, :default => false
    
    # remove uniqueness constraint from address index
    remove_index :addresses, :name => "index_addresses_on_addressable_id_and_addressable_type"
    add_index :addresses, [:addressable_id, :addressable_type], :name => "index_addresses_on_addressable_id_and_addressable_type"
  end
  
  def down
    remove_column :addresses, :billing
    
    remove_index :addresses, :name => "index_addresses_on_addressable_id_and_addressable_type"
    add_index :addresses, [:addressable_id, :addressable_type], :name => "index_addresses_on_addressable_id_and_addressable_type"
  end
end
