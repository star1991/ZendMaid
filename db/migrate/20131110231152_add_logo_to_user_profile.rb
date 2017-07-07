class AddLogoToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :logo, :string
  end
end
