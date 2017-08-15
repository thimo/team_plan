class RenameClubDataTeamsIdInTeams < ActiveRecord::Migration[5.1]
  def change
    rename_column :teams, :club_data_teams_id, :club_data_team_id
  end
end
