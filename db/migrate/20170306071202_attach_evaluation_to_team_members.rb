class AttachEvaluationToTeamMembers < ActiveRecord::Migration[5.1]
  def change
    add_reference :player_evaluations, :team_member, index: true, foreign_key: true

    remove_column :player_evaluations, :field_position
    remove_column :player_evaluations, :prefered_foot
    remove_column :player_evaluations, :member_id
  end
end
