class AddCustomCssToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :custom_css, :text
  end
end
