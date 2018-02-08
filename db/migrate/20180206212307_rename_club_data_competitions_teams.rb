class RenameClubDataCompetitionsTeams < ActiveRecord::Migration[5.1]
  def change
    rename_table :club_data_competitions_teams, :competitions_teams
  end
end
