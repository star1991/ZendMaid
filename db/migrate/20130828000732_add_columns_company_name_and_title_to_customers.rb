class AddColumnsCompanyNameAndTitleToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :company_name, :string
    add_column :customers, :title, :string
  end
end
