class AddEntranceSurveyColumnsToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :why_sign_up, :text
    add_column :user_profiles, :current_management, :text
    add_column :user_profiles, :specific_features, :text
    add_column :user_profiles, :struggles, :text
  end
end
