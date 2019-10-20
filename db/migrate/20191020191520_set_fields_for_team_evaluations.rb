class SetFieldsForTeamEvaluations < ActiveRecord::Migration[6.0]
  def change
    TeamEvaluation.update_all(fields: TeamEvaluationConfig::DEFAULT_CONFIG)
  end
end
