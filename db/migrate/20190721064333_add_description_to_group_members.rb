class AddDescriptionToGroupMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :group_members, :description, :string
  end
end
