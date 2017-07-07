class CreateAuths < ActiveRecord::Migration
  def change
    create_table :auths do |t|
      t.string  :oauth_token
      t.string  :oauth_secret
      t.integer :user_id
      t.string  :provider
      t.string  :dc
      t.string  :list_id
      t.string  :name
      t.string  :provider_id

      t.timestamps
    end
  end
end
