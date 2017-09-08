class AddUniqueIndexToClubDataCompetitionClubDataTeams < ActiveRecord::Migration[5.1]
  def change
    remove_index :club_data_competitions_teams, name: 'competition_team'
    remove_index :club_data_competitions_teams, name: 'team_competition'
    add_index :club_data_competitions_teams, [:club_data_competition_id, :club_data_team_id], name: 'competition_team', unique: true
    add_index :club_data_competitions_teams, [:club_data_team_id, :club_data_competition_id], name: 'team_competition', unique: true
  end
end
