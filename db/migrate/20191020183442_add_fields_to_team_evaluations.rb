class AddFieldsToTeamEvaluations < ActiveRecord::Migration[6.0]
  def change
    add_column :team_evaluations, :fields, :jsonb
  end
end
