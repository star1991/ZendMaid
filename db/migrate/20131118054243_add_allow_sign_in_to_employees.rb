class AddAllowSignInToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :allow_sign_in, :boolean, :default => false
  end
end
