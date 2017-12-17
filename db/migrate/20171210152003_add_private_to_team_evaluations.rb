class AddPrivateToTeamEvaluations < ActiveRecord::Migration[5.1]
  def change
    add_column :team_evaluations, :private, :boolean, default: true
  end
end
