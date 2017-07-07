class AddMarketingSourceToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :marketing_source, :string
  end
end
