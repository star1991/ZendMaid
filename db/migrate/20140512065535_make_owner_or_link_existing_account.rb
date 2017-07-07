class MakeOwnerOrLinkExistingAccount < ActiveRecord::Migration
  def up
    User.reset_column_information
    
    User.all.each do |user|
      employee = Employee.find_by_email(user.email)
      
      if employee.nil?
        employee = user.employees.build(:email => user.email, :phone_number => user.phone_number, :first_name => "Owner")
      end
      
      employee.owner = true
      employee.allow_sign_in = true
      employee.assignable = true
      employee.admin = true
      
      employee.encrypted_password = user.encrypted_password
      employee.save!
      
    end
  end

  def down
  end
end
