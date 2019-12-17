class AddHideRemarkFromPlayerToTeamEvaluations < ActiveRecord::Migration[6.0]
  def change
    add_column :team_evaluations, :hide_remark_from_player, :boolean, default: false
  end
end
