class AddColumnEmbedToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :embed, :boolean, :default => false
  end
end
