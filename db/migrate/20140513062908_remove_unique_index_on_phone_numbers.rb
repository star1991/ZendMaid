class RemoveUniqueIndexOnPhoneNumbers < ActiveRecord::Migration
  def up
    remove_index :phone_numbers, :name => "index_phone_numbers_polymorphic"
    add_index :phone_numbers, [:phone_numberable_id, :phone_numberable_type], :name => "index_phone_numbers_polymorphic"
  end

  def down
  end
end
