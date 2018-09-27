class AddGroupMemberableToGroupMembers < ActiveRecord::Migration[5.2]
  def change
    add_reference :group_members, :memberable, polymorphic: true
  end
end
