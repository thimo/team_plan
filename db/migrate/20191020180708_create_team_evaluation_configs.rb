class CreateTeamEvaluationConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :team_evaluation_configs do |t|
      t.string :name
      t.integer :status
      t.jsonb :fields

      t.timestamps
    end
  end
end
