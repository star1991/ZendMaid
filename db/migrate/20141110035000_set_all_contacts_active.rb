class SetAllContactsActive < ActiveRecord::Migration
  def up
    Customer.update_all({:active => true, :lead => false})
  end

  def down
  end
end
