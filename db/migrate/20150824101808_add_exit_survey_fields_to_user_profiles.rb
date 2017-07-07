class AddExitSurveyFieldsToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :why_leaving, :text
    add_column :user_profiles, :previous_system, :text
    add_column :user_profiles, :intented_new_system, :text
    add_column :user_profiles, :required_specific_feature, :text
    add_column :user_profiles, :recommendation, :integer
    add_column :user_profiles, :other_feedback, :text
  end
end
