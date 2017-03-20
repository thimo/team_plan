class CreateJoinTableFieldPositionsTeamMembers < ActiveRecord::Migration[5.1]
  def change
    create_join_table :field_positions, :team_members do |t|
      t.index [:field_position_id, :team_member_id], name: 'position_member_index'
      t.index [:team_member_id, :field_position_id], name: 'member_position_index'
    end
  end
end
