class AddSentOnToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :sent_on, :text
  end
end
