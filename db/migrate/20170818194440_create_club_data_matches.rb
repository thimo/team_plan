class CreateClubDataMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :club_data_matches do |t|
      t.datetime :wedstrijddatum
      t.integer :wedstrijdcode
      t.integer :wedstrijdnummer
      t.string :thuisteam
      t.string :uitteam
      t.string :thuisteamclubrelatiecode
      t.string :uitteamclubrelatiecode
      t.string :accommodatie
      t.string :plaats
      t.string :wedstrijd
      t.integer :thuisteamid
      t.integer :uitteamid
      t.references :club_data_competition, foreign_key: true
      t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
