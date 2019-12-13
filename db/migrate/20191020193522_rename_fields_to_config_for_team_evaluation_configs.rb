class RenameFieldsToConfigForTeamEvaluationConfigs < ActiveRecord::Migration[6.0]
  def change
    rename_column :team_evaluation_configs, :fields, :config
  end
end
