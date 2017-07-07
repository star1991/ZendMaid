class AddBasePriceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :base_price, :decimal, :precision => 8, :scale => 2, :default => 70.00
  end
end
