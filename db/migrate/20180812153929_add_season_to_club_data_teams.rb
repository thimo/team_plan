class AddSeasonToClubDataTeams < ActiveRecord::Migration[5.2]
  def change
    add_reference :club_data_teams, :season, foreign_key: true
    remove_index :club_data_teams, :teamcode
    add_index :club_data_teams, [:season_id, :teamcode], unique: true
  end
end
