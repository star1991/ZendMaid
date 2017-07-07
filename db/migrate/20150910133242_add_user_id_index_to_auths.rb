class AddUserIdIndexToAuths < ActiveRecord::Migration
  def change
    add_index :auths, :user_id
  end
end
