class MoveContactInfoToNewTables < ActiveRecord::Migration
  def up
    Customer.reset_column_information
    Customer.all.each do |c|
      if c.phone_number.present?
        c.phone_numbers.build(:phone_number_type => "Home", :phone_number => c.phone_number)
      end
      
      if c.email.present?
        c.emails.build(:address => c.email)
      end
      
      c.save!
      if c.service_addresses.size > 0
        billing_address = c.service_addresses.first.dup
        billing_address.billing = true
        billing_address.save!
      end
           
    end
    
    remove_index :customers, :email
    
    remove_column :customers, :phone_number
    remove_column :customers, :email
  end

  def down
    add_column :customers, :email, :string
    add_column :customers, :phone_number, :string
  end
end
