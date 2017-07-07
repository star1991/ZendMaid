class AddNameAndDefaultsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :allow_employee_sign_in, :boolean, :default => false
    add_column :users, :default_employee_password, :string
    add_column :users, :default_pay_type, :string
    add_column :users, :default_pay_rate, :decimal, :precision => 8, :scale => 2
    add_column :users, :free_trial_end, :datetime
  end
end
