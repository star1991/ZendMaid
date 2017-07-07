class AddWhereHearToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :where_hear_about_us, :text
  end
end
