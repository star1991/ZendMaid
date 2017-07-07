class DeleteCvcColumnFromCreditCard < ActiveRecord::Migration
  def up
  	remove_column :credit_cards, :cvc
  end

  def down
  	add_column :credit_cards, :cvc
  end
end
