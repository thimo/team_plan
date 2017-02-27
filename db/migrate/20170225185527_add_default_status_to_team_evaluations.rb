class AddDefaultStatusToTeamEvaluations < ActiveRecord::Migration[5.1]
  def change
    change_column :team_evaluations, :status, :integer, default: 0
  end
end
