class AddOnboardingColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :completed_onboarding, :boolean, :default => false
    add_column :users, :onboarding_page, :integer, :default => 1
  end
end
