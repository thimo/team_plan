class RenameClubDataMatchesTeams < ActiveRecord::Migration[5.1]
  def change
    rename_table :club_data_matches_teams, :matches_teams
    rename_column :matches_teams, :club_data_match_id, :match_id
  end
end
