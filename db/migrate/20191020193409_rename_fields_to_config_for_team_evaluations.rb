class RenameFieldsToConfigForTeamEvaluations < ActiveRecord::Migration[6.0]
  def change
    rename_column :team_evaluations, :fields, :config
  end
end
