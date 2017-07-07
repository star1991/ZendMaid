class AddPayStructureToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :pay_type, :string
    add_column :employees, :pay_rate, :decimal, :precision => 8, :scale => 2
  end
end
