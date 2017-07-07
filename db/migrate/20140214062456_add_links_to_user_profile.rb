class AddLinksToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :website, :text
    add_column :user_profiles, :facebook_page, :text
  end
end
