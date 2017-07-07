class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.string :phone_number
      t.string :phone_number_type
      t.boolean :primary, :default => false
      t.references :phone_numberable, :polymorphic => true

      t.timestamps
    end

    add_index :phone_numbers, [:phone_numberable_id, :phone_numberable_type], :name => "index_phone_numbers_polymorphic"
  end
end
