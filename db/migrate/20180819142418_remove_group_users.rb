class RemoveGroupUsers < ActiveRecord::Migration[5.2]
  def change
    drop_table :group_users
  end
end
