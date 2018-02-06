class RenameCompetitionsClubDataTeams < ActiveRecord::Migration[5.1]
  def change
    rename_table :competitions_club_data_teams, :club_data_teams_competitions
  end
end
