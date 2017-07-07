class CreatePaymentGateways < ActiveRecord::Migration
  def change
    create_table :payment_gateways do |t|
      t.integer :user_id
      t.string :gateway_name, :default => "Stripe"
      t.text :stripe_api_key

      t.timestamps
    end

    add_index :payment_gateways, :user_id
    add_column :users, :allow_cc_processing, :boolean, :default => false
  end
end
