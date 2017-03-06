class RenameEvaluationsToPlayerEvaluations < ActiveRecord::Migration[5.1]
  def change
    rename_table :evaluations, :player_evaluations
  end
end
