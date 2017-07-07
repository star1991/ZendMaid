class AddBasePriceToServiceType < ActiveRecord::Migration
  def up
    add_column :service_types, :base_price, :decimal, :precision => 8, :scale => 2, :default => 0.00
    remove_column :users, :base_price
  end
  
  def down
    remove_column :service_types, :base_price
    add_column :users, :base_price, :decimal, :precision => 8, :scale => 2, :default => 70.00
  end
end
