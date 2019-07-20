class AddStatusToGroupMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :group_members, :status, :integer, default: 1
    add_column :group_members, :started_on, :date
    add_column :group_members, :ended_on, :date
  end
end
