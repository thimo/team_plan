class AddStatusDatesToTeamEvaluations < ActiveRecord::Migration[5.1]
  def change
    add_column :team_evaluations, :invited_at, :datetime
    add_column :team_evaluations, :finished_at, :datetime
    remove_column :team_evaluations, :status
  end
end
