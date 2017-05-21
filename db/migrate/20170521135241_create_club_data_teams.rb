class CreateClubDataTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :club_data_teams do |t|
      t.integer :teamcode, null: false
      t.string :teamnaam
      t.string :spelsoort
      t.string :geslacht
      t.string :teamsoort
      t.string :leeftijdscategorie
      t.string :kalespelsoort
      t.string :speeldag
      t.string :speeldagteam

      t.timestamps
      t.index :teamcode, unique: true
    end

  end
end
