class RenameCompetitionsTeams < ActiveRecord::Migration[5.1]
  def change
    rename_table :competitions_teams, :competitions_club_data_teams
  end
end
