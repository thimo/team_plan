class RemoveUserMembers < ActiveRecord::Migration[5.2]
  def change
    drop_table :user_members
  end
end
