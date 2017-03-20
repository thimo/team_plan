class RemoveFieldPositionReferenceFromTeamMembers < ActiveRecord::Migration[5.1]
  def change
    remove_reference :team_members, :field_position, foreign_key: true
  end
end
