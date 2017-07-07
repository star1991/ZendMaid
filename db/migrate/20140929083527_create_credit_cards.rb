class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.integer :customer_id
      t.string :masked_card_number
      t.integer :expiry_month
      t.integer :expiry_year
      t.string :cvc
      t.text :token
      t.string :card_type

      t.timestamps
    end

    add_index :credit_cards, :customer_id
  end
end
