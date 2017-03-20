class AddFieldPositionToTeamMembers < ActiveRecord::Migration[5.1]
  def change
    add_reference :team_members, :field_position, foreign_key: true
  end
end
