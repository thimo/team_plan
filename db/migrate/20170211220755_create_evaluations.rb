class CreateEvaluations < ActiveRecord::Migration[5.0]
  def change
    create_table :evaluations do |t|
      t.references :team_evaluation, foreign_key: true
      t.references :member, foreign_key: true
      t.string :field_position
      t.string :prefered_foot
      t.string :advise_next_season
      t.string :behaviour
      t.string :technique
      t.string :handlingspeed
      t.string :insight
      t.string :passes
      t.string :speed
      t.string :locomotion
      t.string :physical
      t.string :endurance
      t.string :duel_strength

      t.timestamps
    end
  end
end
