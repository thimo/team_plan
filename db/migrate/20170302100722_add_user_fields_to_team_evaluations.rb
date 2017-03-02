class AddUserFieldsToTeamEvaluations < ActiveRecord::Migration[5.1]
  def change
    add_reference :team_evaluations, :invited_by, references: :users, index: true
    add_foreign_key :team_evaluations, :users, column: :invited_by_id
    add_reference :team_evaluations, :finished_by, references: :users, index: true
    add_foreign_key :team_evaluations, :users, column: :finished_by_id
  end
end
