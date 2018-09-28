class AddUniqueIndexToGroupMembers < ActiveRecord::Migration[5.2]
  def change
    add_index :group_members, [:group_id, :member_id, :memberable_type, :memberable_id], unique: true, name: "index_group_members_unique"
  end
end
