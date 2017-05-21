class CreateClubDataCompetities < ActiveRecord::Migration[5.1]
  def change
    create_table :club_data_competities do |t|
      t.integer :poulecode, null: false
      t.string :competitienaam
      t.string :klasse
      t.string :poule
      t.string :klassepoule
      t.string :competitiesoort
      t.references :club_data_team, foreign_key: true

      t.timestamps
      t.index :poulecode, unique: true
    end

  end
end
