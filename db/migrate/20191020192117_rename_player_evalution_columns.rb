class RenamePlayerEvalutionColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :player_evaluations, :behaviour, :field_1
    rename_column :player_evaluations, :technique, :field_2
    rename_column :player_evaluations, :handlingspeed, :field_3
    rename_column :player_evaluations, :insight, :field_4
    rename_column :player_evaluations, :passes, :field_5
    rename_column :player_evaluations, :speed, :field_6
    rename_column :player_evaluations, :locomotion, :field_7
    rename_column :player_evaluations, :physical, :field_8
    rename_column :player_evaluations, :endurance, :field_9
    rename_column :player_evaluations, :duel_strength, :field_10
  end
end
