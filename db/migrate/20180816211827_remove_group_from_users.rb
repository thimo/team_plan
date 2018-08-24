class RemoveGroupFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :group_id
  end
end
