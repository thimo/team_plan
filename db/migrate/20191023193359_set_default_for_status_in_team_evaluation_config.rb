class SetDefaultForStatusInTeamEvaluationConfig < ActiveRecord::Migration[6.0]
  def change
    change_column :team_evaluation_configs, :status, :integer, default: 0
  end
end
