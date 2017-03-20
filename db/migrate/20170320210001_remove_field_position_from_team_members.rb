class RemoveFieldPositionFromTeamMembers < ActiveRecord::Migration[5.1]
  def change
    remove_column :team_members, :field_position
  end
end
